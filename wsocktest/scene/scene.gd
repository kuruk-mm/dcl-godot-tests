tool
extends Spatial


signal received_event(scene)

const COMPONENT = preload("res://interfaces/component.gd")
const EVENT = preload("res://interfaces/event.gd")
const PROTO = preload("res://server/engineinterface.gd")
const WAYPOINT = preload("res://ui/waypoint/waypoint.tscn")
const parcel_size = 16

var peer = null
var global_scene
var id


var current_index = -1
var entities = {"0": get_node(".")}
var components: Dictionary


func create(msg, p_peer, is_global):
	id = msg.payload.id
	global_scene = is_global

	peer = p_peer

	if msg.payload.name != "DCL Scene":
		ContentManager.load_contents(self, msg.payload)

	if msg.payload.contents.size() > 0:
		transform.origin = Vector3(msg.payload.basePosition.x, 0, msg.payload.basePosition.y) * parcel_size


func contents_loaded():
	var response = {"eventType":"SceneReady", "payload": {"sceneId": id}}
	Server.send({"type": "ControlEvent", "payload": JSON.print(response)}, peer)


func message(scene_msg: PROTO.PB_SendSceneMessage):
	#print(scene_msg.to_string())

	if scene_msg.has_createEntity():
		#print("create entity ", scene_msg.get_createEntity().get_id())
		var entity_id = scene_msg.get_createEntity().get_id()
		entities[entity_id] = Spatial.new()
		entities[entity_id].name = entity_id
		add_child(entities[entity_id])

	if scene_msg.has_removeEntity():
		pass#print("remove entity ", scene_msg.get_removeEntity().get_id())

	if scene_msg.has_setEntityParent():
#		print("setEntityParent %s -> %s" % [
#			scene_msg.get_setEntityParent().get_parentId(),
#			scene_msg.get_setEntityParent().get_entityId() ])
		reparent(
			scene_msg.get_setEntityParent().get_entityId(),
			scene_msg.get_setEntityParent().get_parentId()
		)

	if scene_msg.has_componentCreated():
		#print("component created ", scene_msg.get_componentCreated().get_name())
		var classid = scene_msg.get_componentCreated().get_classid()
		var c_id = scene_msg.get_componentCreated().get_id()
		var c_name = scene_msg.get_componentCreated().get_name()
		match classid:
			DCL_BoxShape._classid:
				components[c_id] = DCL_BoxShape.new(c_name)
			DCL_SphereShape._classid:
				components[c_id] = DCL_SphereShape.new(c_name)
			DCL_Material._classid:
				components[c_id] = DCL_Material.new(c_name)
			DCL_GLTFShape._classid:
				components[c_id] = DCL_GLTFShape.new(c_name)
			_:
				print("Unimplemented component")
				components[c_id] = DCL_Component.new(c_name)

	if scene_msg.has_componentDisposed():
		pass#print("component disposed ", scene_msg.get_componentDisposed().get_id())

	if scene_msg.has_componentRemoved():
		pass#print("component removed ", scene_msg.get_componentRemoved().get_name())

	if scene_msg.has_componentUpdated():
#		print("component updated %s -> %s" % [
#			scene_msg.get_componentUpdated().get_id(),
#			scene_msg.get_componentUpdated().get_json() ])
		components[scene_msg.get_componentUpdated().get_id()].update(
			scene_msg.get_componentUpdated().get_json()
		)

	if scene_msg.has_attachEntityComponent():
		#print("attach component to entity %s -> %s" % [
#			scene_msg.get_attachEntityComponent().get_entityId(),
#			scene_msg.get_attachEntityComponent().get_id() ])

		components[scene_msg.get_attachEntityComponent().get_id()].attach_to(
			entities[scene_msg.get_attachEntityComponent().get_entityId()]
		)

	if scene_msg.has_updateEntityComponent():

		var classid = scene_msg.get_updateEntityComponent().get_classId()
		var data = scene_msg.get_updateEntityComponent().get_data()
		var entity_id = scene_msg.get_updateEntityComponent().get_entityId()

#		print("update component in entity %s -> %s" % [
#			entity_id,
#			data ])

		# check this classid in engineinterface.proto (line 24)
		match classid:
			8: # PB_UUIDCallback
				var entity = entities[entity_id]
				var parsed = JSON.parse(data).result
				if parsed.has("uuid"):
					if has_meta("events"):
						get_meta("events").append(EVENT.new(id, entity, parsed))
					else:
						set_meta("events", [EVENT.new(id, entity, parsed)])

				if parsed.has("outlineWidth"):
					var w = WAYPOINT.instance()
					var label = w.get_node("Label") as Label
					var font = label.get("custom_fonts/font") as DynamicFont
					w.text = parsed.value
					label.set("custom_colors/font_color", Color(parsed.color.r, parsed.color.g, parsed.color.b))
					font.outline_color = Color(parsed.outlineColor.r, parsed.outlineColor.g, parsed.outlineColor.b)
					font.outline_size = parsed.outlineWidth
					entity.add_child(w)

				if parsed.has("states") and entity.has_node("AnimationPlayer"):
					var anim_node = entity.get_node("AnimationPlayer") as AnimationPlayer
					for anim in parsed.states:
						if anim.playing and anim_node.has_animation(anim.clip):
							print(anim)
							anim_node.get_animation(anim.clip).loop = anim.looping
							anim_node.playback_speed = anim.speed
							anim_node.play(anim.clip)
							break

				emit_signal("received_event", self)
			1: # PB_Transform
				var buf = Marshalls.base64_to_raw(data)

				var comp = PROTO.PB_Transform.new()
				var err = comp.from_bytes(buf)
				if err == PROTO.PB_ERR.NO_ERRORS:
					var rot = comp.get_rotation()
					var pos = comp.get_position()
					var sca = comp.get_scale()

#					print("update component in entity %s transform -> %s" % [
#						scene_msg.get_updateEntityComponent().get_entityId(),
#						comp.to_string() ])

					var q = Quat(
						rot.get_x(),
						rot.get_y(),
						rot.get_z(),
						rot.get_w()
					)
					entities[entity_id].transform = Transform(q).scaled(Vector3(sca.get_x(), sca.get_y(), sca.get_z()))
					entities[entity_id].transform.origin = Vector3(pos.get_x(), pos.get_y(), pos.get_z())
				else:
					push_warning("****** error decoding PB_Transform payload %s" % err)
			_:
				pass#printt("updateEntityComponent ****", classid)

	if scene_msg.has_sceneStarted():
		pass#print("scene started ", id)

	if scene_msg.has_openNFTDialog():
		pass#print("open NFT dialog %s %s" % [
#			scene_msg.get_openNFTDialog().get_assetContractAddress(),
#			scene_msg.get_openNFTDialog().get_tokenId()
#		])

	if scene_msg.has_query():
		pass#print("query ", scene_msg.get_query().get_payload())


func reparent(src, dest):
	var src_node = entities[src]
	var dest_node = entities[dest]
	src_node.get_parent().remove_child(src_node)
	dest_node.add_child(src_node)


#func _input(event):
#	if has_meta("events"):
#		for e in get_meta("events"):
#			e.check(event)


func _get_configuration_warning():
	return "" if peer == null else "Scene is currently connected to a peer." +\
			"\nRemoving the DebuggerDump off the tree will completely detach this scene from it."
