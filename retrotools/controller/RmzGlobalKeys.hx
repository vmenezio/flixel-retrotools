package retrotools.controller;

import flixel.input.keyboard.FlxKey;

/**
 * ...
 * @author ...
 */
class RmzGlobalKeys
{

	private function new() { }
	
	public inline static var KEYBOARD = 0;
	public inline static var GAMEPAD = 1;
	
	public static var MODE:UInt = KEYBOARD;
	
	public static var UP:Array<Int> = [FlxKey.UP];
	public static var DOWN:Array<Int> = [FlxKey.DOWN];
	public static var LEFT:Array<Int> = [FlxKey.LEFT];
	public static var RIGHT:Array<Int> = [FlxKey.RIGHT];
	
	public static var OK:Array<Int> = [FlxKey.ENTER];
	
	public static var PRIMARY:Array<Int> = [FlxKey.Z];
	public static var SECONDARY:Array<Int> = [FlxKey.X];
	public static var TERTIARY:Array<Int> = [FlxKey.C];
	
}