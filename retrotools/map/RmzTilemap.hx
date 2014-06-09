package retrotools.map ;

// Haxe Imports
import haxe.io.Path;

// Core Flixel Imports
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.FlxG;

// Tiled Imports
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;

/**
 * The <b>RmzTilemap</b> class facilitates the use of Tiled tilemaps, providing methods to allow
 * easy access to the properties, tile layers and object layers contained in a .tmx file.
 * 
 * @author Vinícius Menézio
 */

class RmzTilemap {
	
	private inline static var TILESETS_PATH = "assets/images/tilesets/";
	private var rawTilemap:TiledMap;
	
	public var indexedLayers:Map<String, FlxTilemap>;

	/**
	 * Creates a <b>RmzTilemap</b> from a specified Tiled map file (.tmx).
	 * 
	 * @param	tmxPath			<b>String</b> pointing to the path where the .tmx file is stored.
	 */
	public function new( tmxPath:String ) {
		rawTilemap = new TiledMap( tmxPath );
		indexedLayers = generateLayerMap( rawTilemap.layers );
	}
	
	/**
	 * Returns a new <b>FlxGroup</b> containing the sprites corresponding to the specified <i>Type</i> retrieved from the map. 
	 * Returns all sprites if no Type is specified.
	 * 
	 * @param	desiredType		<b>String</b> referencing which <i>Type</i> (internal property of Tiled objects) of objects must be inserted into the group. 
	 * @return	A new <b>FlxGroup</b> filled with <b>FlxSprites</b> made up from the specified <i>Type</i>.
	 */
	public function getObjectGroup( desiredType:String = null ):FlxGroup {
		var returnGroup:FlxGroup = new FlxGroup();
		
		for (group in rawTilemap.objectGroups) {
			for (o in group.objects) {
				var object:RmzTiledObject = generateRmzTiledObject(o, group, desiredType);
				
				if (object != null)
					returnGroup.add(object.getSprite());
			}
		}
		
		return returnGroup;
	}
	
	/**
	 * Returns a <b>FlxTilemap</b> containing the tiles of the specified tilemap layer.
	 * 
	 * @param	layerName		<b>String</b> of the name of the tilemap layer.
	 * @return	A <b>FlxTilemap</b> created from the tiles of the tilemap layer.
	 */
	public function getTileLayer( layerName:String ):FlxTilemap {
		var returnLayer = indexedLayers.get( layerName );
		if ( returnLayer == null ) {
			throw "Layer with name '" + layerName + "' not found within the .tmx file.";
		} else {
			return returnLayer;
		}
	}
	
	/**
	 * Specifies <b>Flx.camera</b> boundries to match those of the tilemap.
	 */
	public function alignCamera():Void {
		FlxG.camera.setBounds(0, 0, rawTilemap.fullWidth, rawTilemap.fullHeight, true);
	}
	
	/**
	 * Reads an internal map property from the .tmx file and returns it in <b>String</b> format.
	 * 
	 * @param	propertyName	<b>String</b> of the internal identifier of the map property.
	 * @return	A <b>String</b> containing the value of the property.
	 */
	public function getProperty( propertyName:String ):String {
		var returnString:String = rawTilemap.properties.keys.get( propertyName );
		if ( returnString == null ) {
			throw "Property with name '" + propertyName + "' not found within the .tmx file.";
		} else {
			return returnString;
		}
	}
	
	/**
	 * Reads a <b>TiledObject</b> from a specified <b>TiledObjectGroup</b> and returns a <b>RmzTiledObject</b> created from it's properties.
	 * 
	 * @param	rawObject		<b>TiledObject</b> to serve as base for the resulting <b>RmzTiledObject</b>.
	 * @param	objectGroup		<b>TiledObjectGroup</b> containing the rawObject.
	 * @param	desiredType		<b>String</b> referencing the internal <i>Type</i> attribute of the rawObject.
	 * @return	A <b>RmzTiledObject</b> created from the properties of the rawObject.
	 */
	private function generateRmzTiledObject( rawObject:TiledObject, objectGroup:TiledObjectGroup, desiredType:String ):RmzTiledObject {
		var x:Int = rawObject.x;
		var y:Int = rawObject.y;
		var width:Int = rawObject.width;
		var height:Int = rawObject.height;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (rawObject.gid != -1)
			y -= objectGroup.map.getGidOwner(rawObject.gid).tileHeight;
		
		var TempClass:Class<Dynamic> = Type.resolveClass("tiledObjects."+rawObject.type);
		var tempObject:RmzTiledObject;
		
		if (desiredType != null && rawObject.type != desiredType)
			return null
		else if (TempClass != null)
			tempObject = Type.createInstance(TempClass, [x, y, width, height, rawObject.custom.keys]);
		else
			throw "Class " + rawObject.type + " not found among the valid classes. Please add it to the 'tiledObjects' package of your project.";
			
		return tempObject;
	}
	
	/**
	 * Reads a <b>TiledLayer</b> and returns a <b>FlxTilemap</b> created from it's properties.
	 * 
	 * @param	tmxLayer		<b>TiledLayer</b> to serve as base for the resulting <b>FlxTilemap</b>.
	 * @return	A <b>FlxTilemap</b> created from the tmxLayer.
	 */
	private function generateFlxTilemap( tmxLayer:TiledLayer ):FlxTilemap {
		
		var tilesetName:String = tmxLayer.properties.get("tileset");
			
			if (tilesetName == null)
				throw "'tileset' property not defined for the '" + tmxLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in rawTilemap.tilesets) {
				if (ts.name == tilesetName) {
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tilesetName + " not found. Did you mispell the 'tilesheet' property in the '" + tmxLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= TILESETS_PATH + imagePath.file + "." + imagePath.ext;
			
			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.widthInTiles = rawTilemap.width;
			tilemap.heightInTiles = rawTilemap.height;
			tilemap.loadMap(tmxLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);
			
			return tilemap;
	}
	
	/**
	 * Generates a <b>Map</b> that associates the name of each layer from a .tmx file to it's respective <b>FlxTilemap</b>
	 * 
	 * @param	layerArray		<b>Array</b> containing the <b>TiledLayers</b> from the .tmx file.
	 * @return	A <b>Map</b> associating <b>FlxTilemaps</b> (values) to <b>Strings</b> containing the name of the layers (keys) they were created from.
	 */
	private function generateLayerMap( layerArray:Array<TiledLayer> ):Map<String, FlxTilemap> {
		
		var returnMap:Map<String, FlxTilemap> = new Map();
		
		for ( tmxLayer in layerArray ) {
			returnMap.set(tmxLayer.name, generateFlxTilemap(tmxLayer));
		}
		
		return returnMap;
		
	}

}