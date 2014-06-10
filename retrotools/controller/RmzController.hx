package retrotools.controller;

// Core Flixel Imports
import flixel.FlxG;

/**
 * The <b>RmzController</b> class binds key presses - or combinations of key presses - to methods
 * that need to be reused multiple times.
 * 
 * @author Vinícius Menézio
 */
class RmzController
{
	
	// TODO: add support for successive and simultaneous key presses.
	// TODO: add support for unbinding keys.
	
	// Single-key action maps
	private var pressedActionMap:Map < Int,Dynamic > ;
	private var justPressedActionMap:Map < Int, Dynamic > ;
	private var justReleasedActionMap:Map < Int, Dynamic > ;

	/**
	 * Creates a new <b>RmzController</b>.
	 */
	public function new() {
		pressedActionMap = new Map();
		justPressedActionMap = new Map();
		justReleasedActionMap = new Map();
	}
	
	/**
	 * Binds the pressing and holding of a key to a specified method.
	 * 
	 * @param	key			<b>Int</b> containing the index of the key, as per specified in the <b>FlxKey</b> class.
	 * @param	action		<b>Dynamic</b> representing the method to be called when the specified key is pressed.
	 * @param	params		<b>Array<Dynamic></b> containing the parameters to be passed to the specified method.
	 */
	public function bindPressed( key:Int, action:Dynamic, ?params:Array<Dynamic> ):Void {
		pressedActionMap.set( key, { action:action, params:params } );
	}
	
	/**
	 * Binds the immediate pressing of a key to a specified method.
	 * 
	 * @param	key			<b>Int</b> containing the index of the key, as per specified in the <b>FlxKey</b> class.
	 * @param	action		<b>Dynamic</b> representing the method to be called when the specified key is pressed.
	 * @param	params		<b>Array<Dynamic></b> containing the parameters to be passed to the specified method.
	 */
	public function bindJustPressed( key:Int, action:Dynamic, ?params:Array<Dynamic> ):Void {
		justPressedActionMap.set( key, { action:action, params:params } );
	}
	
	/**
	 * Binds the immediate releasing of a key to a specified method.
	 * 
	 * @param	key			<b>Int</b> containing the index of the key, as per specified in the <b>FlxKey</b> class.
	 * @param	action		<b>Dynamic</b> representing the method to be called when the specified key is pressed.
	 * @param	params		<b>Array<Dynamic></b> containing the parameters to be passed to the specified method.
	 */
	public function bindJustReleased( key:Int, action:Dynamic, ?params:Array<Dynamic> ):Void {
		justReleasedActionMap.set( key, { action:action, params:params } );
	}
	
	/**
	 * Checks whether the key bindings defined for this controller are active, and runs the appropriate 
	 * methods for those that are.
	 */
	public function checkKeyPress():Void {
		for ( key in pressedActionMap.keys() ) {
			if ( FlxG.keys.pressed.check( key ) ) {
				Reflect.callMethod( { }, pressedActionMap.get( key ).action, pressedActionMap.get( key ).params );
			}
		}
		for ( key in justPressedActionMap.keys() ) {
			if ( FlxG.keys.justPressed.check( key ) ) {
				Reflect.callMethod( { }, justPressedActionMap.get( key ).action, justPressedActionMap.get( key ).params );
			}
		}
		for ( key in justReleasedActionMap.keys() ) {
			if ( FlxG.keys.justReleased.check( key ) ) {
				Reflect.callMethod( { }, justReleasedActionMap.get( key ).action, justReleasedActionMap.get( key ).params );
			}
		}
	}
	
}