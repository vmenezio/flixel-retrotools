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
	private var pressedActionMap:		Map < Array <Int>,Dynamic > ;
	private var justPressedActionMap:	Map < Array <Int>, Dynamic > ;
	private var comboActionMap:			Map < RmzCombo, Dynamic > ;
	private var justReleasedActionMap:	Map < Array <Int>, Dynamic > ;
	
	// Gamepad action maps
	private var gamepadPressedActionMaps:		Array< Map < Array <Int>, Dynamic > > ;
	private var gamepadJustPressedActionMaps:	Array< Map < Array <Int>, Dynamic > > ;
	private var gamepadComboActionMap:			Array< Map < Array <Int>, Dynamic > > ;
	private var gamepadJustReleasedActionMaps:	Array< Map < Array <Int>, Dynamic > > ;

	/**
	 * Creates a new <b>RmzController</b>.
	 */
	public function new() {
		initializeMaps();
	}
	
	/**
	 * Binds the pressing and holding of a key to a specified method.
	 * 
	 * @param	key			<b>Int</b> containing the index of the key, as per specified in the <b>FlxKey</b> class.
	 * @param	action		<b>Dynamic</b> representing the method to be called when the specified key is pressed.
	 * @param	params		<b>Array<Dynamic></b> containing the parameters to be passed to the specified method.
	 */
	public function bindPressed( keys:Array <Int>, action:Dynamic, ?params:Array<Dynamic> ):Void {
		pressedActionMap.set( keys, { action:action, params:params } );
	}
	
	/**
	 * Binds the immediate pressing of a key to a specified method.
	 * 
	 * @param	key			<b>Int</b> containing the index of the key, as per specified in the <b>FlxKey</b> class.
	 * @param	action		<b>Dynamic</b> representing the method to be called when the specified key is pressed.
	 * @param	params		<b>Array<Dynamic></b> containing the parameters to be passed to the specified method.
	 */
	public function bindJustPressed( key:Array <Int>, action:Dynamic, ?params:Array<Dynamic> ):Void {
		justPressedActionMap.set( key, { action:action, params:params } );
	}
	
	public function bindCombo( keys:Array<Int>, delays:Array<Int>, action:Dynamic, ?params:Array<Dynamic> ):Void {
		var combo = new RmzCombo( keys, delays );
		comboActionMap.set( combo, { action:action, params:params } );
	}
	
	/**
	 * Binds the immediate releasing of a key to a specified method.
	 * 
	 * @param	key			<b>Int</b> containing the index of the key, as per specified in the <b>FlxKey</b> class.
	 * @param	action		<b>Dynamic</b> representing the method to be called when the specified key is pressed.
	 * @param	params		<b>Array<Dynamic></b> containing the parameters to be passed to the specified method.
	 */
	public function bindJustReleased( keys:Array <Int>, action:Dynamic, ?params:Array<Dynamic> ):Void {
		justReleasedActionMap.set( keys, { action:action, params:params } );
	}
	
	// Gamepad Bindings
	
	public function bindGamepadPressed( buttons:Array<Int>, gamepadID:Int, action:Dynamic, ?params:Array<Dynamic> ):Void {
		if ( gamepadPressedActionMaps[gamepadID] == null )
			gamepadPressedActionMaps[gamepadID] = new Map();
		gamepadPressedActionMaps[gamepadID].set( buttons, { action:action, params:params } );
	}
	
	public function bindGamepadJustPressed( buttons:Array<Int>, gamepadID:Int, action:Dynamic, ?params:Array<Dynamic> ):Void {
		if ( gamepadJustPressedActionMaps[gamepadID] == null )
			gamepadJustPressedActionMaps[gamepadID] = new Map();
		gamepadJustPressedActionMaps[gamepadID].set( buttons, { action:action, params:params } );
	}
	
	public function bindGamepadJustReleased( buttons:Array<Int>, gamepadID:Int, action:Dynamic, ?params:Array<Dynamic> ):Void {
		if ( gamepadJustReleasedActionMaps[gamepadID] == null )
			gamepadJustReleasedActionMaps[gamepadID] = new Map();
		gamepadJustReleasedActionMaps[gamepadID].set( buttons, { action:action, params:params } );
	}
	
	/**
	 * Checks whether the key bindings defined for this controller are active, and runs the appropriate 
	 * methods for those that are.
	 */
	public function checkKeyPress():Void {
		for ( keys in pressedActionMap.keys() ) {
			for  ( key in keys ) {
				if ( FlxG.keys.pressed.check( key ) ) {
					Reflect.callMethod( null, pressedActionMap.get( keys ).action, pressedActionMap.get( keys ).params );
				}
			}
		}
		for ( keys in justPressedActionMap.keys() ) {
			for  ( key in keys ) {
				if ( FlxG.keys.justPressed.check( key ) ) {
					Reflect.callMethod( null, justPressedActionMap.get( keys ).action, justPressedActionMap.get( keys ).params );
				}
			}
		}
		for ( keys in justReleasedActionMap.keys() ) {
			for  ( key in keys ) {
				if ( FlxG.keys.justReleased.check( key ) ) {
					Reflect.callMethod( null, justReleasedActionMap.get( keys ).action, justReleasedActionMap.get( keys ).params );
				}
			}
		}
		for ( combo in comboActionMap.keys() ) {
			//if ( combo.checkSuccess() ) {
			//
			//}
		}
		
		// Gamepad Checks
		
		for ( gamepadID in 0...gamepadPressedActionMaps.length ) {
			for ( buttons in gamepadPressedActionMaps[gamepadID].keys() ) {
				for  ( button in buttons ) {
					if ( FlxG.gamepads.getByID(gamepadID).pressed( button ) ) {
						Reflect.callMethod( null, gamepadPressedActionMaps[gamepadID].get( buttons ).action,
								gamepadPressedActionMaps[gamepadID].get( buttons ).params );
					}
				}
			}
		}
		
		for ( gamepadID in 0...gamepadJustPressedActionMaps.length ) {
			for ( buttons in gamepadJustPressedActionMaps[gamepadID].keys() ) {
				for  ( button in buttons ) {
					if ( FlxG.gamepads.getByID(gamepadID).justPressed( button ) ) {
						Reflect.callMethod( null, gamepadJustPressedActionMaps[gamepadID].get( buttons ).action, 
								gamepadJustPressedActionMaps[gamepadID].get( buttons ).params );
					}
				}
			}
		}
		
		for ( gamepadID in 0...gamepadJustReleasedActionMaps.length ) {
			for ( buttons in gamepadJustReleasedActionMaps[gamepadID].keys() ) {
				for  ( button in buttons ) {
					if ( FlxG.gamepads.getByID(gamepadID).justReleased( button ) ) {
						Reflect.callMethod( null, gamepadJustReleasedActionMaps[gamepadID].get( buttons ).action, 
								gamepadJustReleasedActionMaps[gamepadID].get( buttons ).params );
					}
				}
			}
		}
	}
	
	private function initializeMaps():Void {
		pressedActionMap = new Map();
		justPressedActionMap = new Map();
		comboActionMap = new Map();
		justReleasedActionMap = new Map();
		
		gamepadPressedActionMaps = new Array();
		gamepadJustPressedActionMaps = new Array();
		gamepadComboActionMap = new Array();
		gamepadJustReleasedActionMaps = new Array();
	}
	
}