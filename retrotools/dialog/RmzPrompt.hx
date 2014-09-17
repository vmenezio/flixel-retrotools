package retrotools.dialog;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxG;
import retrotools.controller.RmzController;
import retrotools.controller.RmzGlobalKeys;

/**
 * ...
 * @author Vinícius Menézio
 */
class RmzPrompt extends RmzDialog
{
	
	private var options:Array<Dynamic>;
	private var response:String;
	public var marginX:Int = 0;
	public var marginY:Int = 0;
	public var color:Int = 0;
	
	private var cursor:FlxText;
	private var currentOption:Int = 0;
	
	public function new( x:Float, y:Float ) {
		super( x, y );
		options = new Array();
		
		cursor = new FlxText( x, y, 0, ">" );
		add( cursor );
		
		loadPresetKeys();
	}
	
	override public function update():Void {
		super.update();
		cursor.x = x + marginX;
		if ( options.length != 0 )
			cursor.y  = y + cast( options[0].text, FlxText ).height*currentOption + marginY;
	}
	
	public function configureKeys( up:Array<Int>, down:Array<Int>, confirm:Array<Int> ) {
		controller = new RmzController();
		controller.bindJustPressed( up, nextOption );
		controller.bindJustPressed( down, previousOption );
		controller.bindJustPressed( confirm, selectOption );
	}
	
	public function configureGamepadButtons( up:Array<Int>, down:Array<Int>, confirm:Array<Int>, gamepadID:Int ) {
		controller = new RmzController();
		controller.bindGamepadJustPressed( up, gamepadID, nextOption );
		controller.bindGamepadJustPressed( down, gamepadID, previousOption );
		controller.bindGamepadJustPressed( confirm, gamepadID, selectOption );
	}
	
	public function addOption( optionText:String, response:String ):Void {
		options.push( { text:new FlxText(0, 0, 0, optionText), response:response } );
		printOptions();
	}
	
	public function resetOptions():Void {
		options = new Array();
	}
	
	public function setLayout( width:Int, height:Int, marginX:Int, marginY:Int, color:Int ):Void {
		this.marginX = marginX;
		this.marginY = marginY;
		this.color = color;
		setBackgroundColor( color, width, height );
	}
	
	public function activate():RmzPrompt {
		super.revive();
		callAll( "revive" );
		response = "";
		return this;
	}
	
	public function getResponse():String {
		if ( this.response != null && this.response != "" ) {
			kill();
			return response;
		}
		return "";
	}
	
	private function printOptions():Void {
		var x = this.x + marginX + Std.int(cursor.width);
		var y = this.y + marginY;
		for ( opt in options ) {
			cast( opt.text, FlxText ).x = x;
			cast( opt.text, FlxText ).y = y;
			add( opt.text );
			y += cast( opt.text, FlxText ).height;
		}
	}
	
	private function nextOption():Void {
		currentOption++;
		if ( currentOption >= options.length )
			currentOption = 0;
	}
	
	private function previousOption():Void {
		currentOption--;
		if ( currentOption < 0 )
			currentOption = options.length-1;
	}
	
	private function selectOption():Void {
		this.response = options[currentOption].response;
	}
	
	override public function revive():Void {
		FlxG.log.warn("<b>RmzPrompts</b> can't be revived through revive(). Call activate() instead.");
	}
	
	public function loadPresetKeys():Void {
		controller = new RmzController();
		switch ( RmzGlobalKeys.MODE ) {
			case RmzGlobalKeys.KEYBOARD: 
				configureKeys( RmzGlobalKeys.UP, RmzGlobalKeys.DOWN, RmzGlobalKeys.PRIMARY );
			case RmzGlobalKeys.GAMEPAD: 
				configureGamepadButtons( RmzGlobalKeys.UP, RmzGlobalKeys.DOWN, RmzGlobalKeys.PRIMARY, 0 );
		}
	}
	
}