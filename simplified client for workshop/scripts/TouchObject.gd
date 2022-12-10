extends Spatial

onready var pathLine=$PathLine
onready var realPath=$Path
onready var realPathFollow=$Path/real_follower


var playing=false
var dist=0
var iter=null
var passed_point=null
var waiting_list=null
var waiting=0
var speed=1
# Called when the node enters the scene tree for the first time.

func _process(delta):
	if(playing):
		if(self.iter==self.pathLine.getAllPoints().size()):
			self.playing=false
			return
	
		self.realPathFollow.offset += delta*self.speed
		#self.realPathFollow.look_at(self.pathLine.getAllPoints()[self.iter].global_transform.origin,self.pathLine.getAllPoints()[self.iter].global_transform.origin)
		self.realPathFollow.rotation_degrees.x=0
		self.realPathFollow.rotation_degrees.z=0
		
		if(self.dist>=self.realPathFollow.global_transform.origin.distance_to(self.pathLine.getAllPoints()[self.iter].global_transform.origin)):
			self.dist=self.realPathFollow.global_transform.origin.distance_to(self.pathLine.getAllPoints()[self.iter].global_transform.origin)
		else:
			self.passed_point.append(self.pathLine.getAllPoints()[self.iter])
			#if(self.pathLine.getAllPoints()[self.iter].type=="base"):
				#print("base")
			
			#if(self.pathLine.getAllPoints()[self.iter].type=="takeoff"):
				#print("takeoff")
			
			#if(self.pathLine.getAllPoints()[self.iter].type=="landing"):
				#print("landing")
			
			if(self.pathLine.getAllPoints()[self.iter].type=="waiting"):
				self.waiting=self.pathLine.getAllPoints()[self.iter].time
				#print("waiting")
			
			if(self.pathLine.getAllPoints()[self.iter].type=="spinning"):
				self.spinning=self.realPathFollow.rotation_degrees.y
				self.state_spinning=true
				#print("spinning")
			
			if(self.pathLine.getAllPoints()[self.iter].type=="meeting"):
				
				for drone in get_tree().get_nodes_in_group("TouchObjects"):
					if !drone.is_in_group("TouchPoints"):
						if drone.playing and drone!=self:
							for point in drone.pathLine.getAllPoints():
								if point.type=="meeting" and point.name_meeting==self.pathLine.getAllPoints()[self.iter].name_meeting:
									self.waiting_list.append([point,drone])
									if !self.wait_meeting:
										self.wait_meeting=true
										
			
			self.iter=self.iter+1
			self.dist=100
		
	

		"""
		self.global_transform.origin.x=pos_x
		self.global_transform.origin.y=pos_y
		self.global_transform.origin.z=pos_z"""
	
		
		"""self.realPathFollow.global_transform.origin.x=pos_x
		self.realPathFollow.global_transform.origin.y=pos_y
		self.realPathFollow.global_transform.origin.z=pos_z"""
		

func _ready():
	print("drone")
	self.pathLine.addPoint(self.global_transform.origin)
	self.pathLine.addTakeOffPoint(1)
	
	self.pathLine.addPoint(Vector3(1,0,0))
	self.pathLine.makeVisisble()
	self.pathLine.addLandingPoint()


func generatePath():
	print("test")
	var _curve = Curve3D.new()
	for pointNode in self.pathLine.getAllPoints():
		_curve.add_point(pointNode.transform.origin)
		
	self.dist=100
	self.iter=1
	self.realPath.set_curve(_curve)
	self.playing=true
	self.passed_point=[]
	self.waiting_list=[]
	self.waiting=0
	#self.realPathFollow.set_rotation_mode(PathFollow.ROTATION_XYZ)


