extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func replace_data_in_file(filePath=false, dataArray=[], createFile=true) -> bool:
	if FileAccess.file_exists(filePath) or createFile:
		print("Replacing data in file: ", filePath, "with data: ", dataArray)
		
		var file = FileAccess.open(filePath, FileAccess.WRITE)
		#var j = JSON.new()
	
		for doc in dataArray:
			file.store_line(JSON.stringify(doc))
		
		print("Data replaced in file: ", filePath)
		
		return true
	else:
		print("Cannot replace data, createFile is false and file doesn't exist at path: ", filePath)
		return false

func append_data_to_file(filePath=false, doc={}, createFile=true) -> void:
	var facc = FileAccess.WRITE
	if FileAccess.file_exists(filePath):
		facc = FileAccess.READ_WRITE
	
	var file = FileAccess.open(filePath, facc)
	file.seek_end()
	
	file.store_line(JSON.stringify(doc))
	file.close()

# has an optional dataCB that should return the new doc
func load_data_from_file(filePath=false, dataCB: Callable=Callable()) -> Array:
	print("LOADING data array from file: ", filePath)
	
	var dataArray = []
	
	if filePath and FileAccess.file_exists(filePath):
		var file = FileAccess.open(filePath, FileAccess.READ)
		
		for line in file.get_as_text().split("\n"):
			#print("Line: ", line)
			if line.length() == 0:
				continue
			
			var doc = JSON.parse_string(line)
			#print("doc: ", doc)
			
			if doc != null:
				if dataCB.is_valid():
					dataArray.push_back(dataCB.call(doc))
				else:
					dataArray.push_back(doc)
		
		file.close()
	
	return dataArray
