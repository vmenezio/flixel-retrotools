package retrotools.map;

// Tiled Imports
import flixel.addons.editors.tiled.TiledObject;

// Core Flixel Imports
import flixel.FlxSprite;

/**
 * The <b>RmzTiledObject</b> class serves to help translate an internal object from a .tmx file,
 * with all it's properties, into a fully functional <b>FlxSprite</b> to be used inside the game.
 * 
 * @author Vinícius Menézio
 */

class RmzTiledObject {
	
	private var rawPropertiesMap:Map<String,String>;
	
	private var x:Float;
	private var y:Float;
	private var width:Float;
	private var height:Float;
	
	private var sprite:FlxSprite;

	/**
	 * Creates a <b>RmzTiledObject</b> from the properties retrieved from an object in a .tmx file.
	 * 
	 * @param	x				<b>Float</b> representing the x coordinate of the object in the tilemap.
	 * @param	y				<b>Float</b> representing the y coordinate of the object in the tilemap.
	 * @param	width			<b>Float</b> representing the width of the object in pixels.
	 * @param	height			<b>Float</b> representing the height of the object in pixels.
	 * @param	propertiesMap	<b>Map < String, String ></b> associating the object's properties and their values.
	 */
	public function new( x:Float, y:Float, width:Float, height:Float, propertiesMap:Map < String, String > ) {
		this.rawPropertiesMap = propertiesMap;
		
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		
		initializeSprite();
	}
	
	/**
	 * Generates a <b>FlxSprite</b> from the attributes of the <b>RmzTiledObject</b>.
	 */
	private function initializeSprite():Void {
		this.sprite = new FlxSprite( x, y );
	}
	
	/**
	 * Returns the <b>RmzTiledObject</b>'s internal <b>FlxSprite</b>.
	 * 
	 * @return	A <b>FlxSprite</b> generated from the attributes of the <b>RmzTiledObject</b>.
	 */
	public function getSprite():FlxSprite {
		return this.sprite;
	}
	
	/**
	 * Retrieves the value of the internal attribute with the specified name as a <b>String</b>.
	 * 
	 * @param	attribute		<b>String</b> representing the name of the attribute being retrieved.
	 * @param	defaultValue	<b>String</b> containing the value that is expected if the desired attribute is not found.
	 * @return
	 */
	private function retrieveAttribute( attribute:String, ?defaultValue:String ):String {
		var returnValue:String = rawPropertiesMap.get( attribute );
		
		if ( returnValue == null ) {
			if ( defaultValue != null ) {
				return defaultValue;
			} else {
				throw "Attribute with name '" + attribute + "' not found within TMX object, and default value not specified.";
			}
		} else {
			return returnValue;
		}
	}
	
}