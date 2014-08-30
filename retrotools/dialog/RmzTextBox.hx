package retrotools.dialog;

// Core Flixel Imports
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;

import retrotools.controller.RmzController;

/**
 * The <b>RmzTextBox</b> class speeds up the creation of text elements such as interfaces,
 * dialogue boxes, credits sequences, among others - allowing for background customizantion
 * and multiple panels of text.
 * 
 * @author Vinícius Menézio
 */
class RmzTextBox extends FlxGroup
{
	
	// TODO: Write documentation for this class
	// TODO: Support multiple panels
	
	public static var NONE:UInt = 0;
	public static var HURRY:UInt = 1;
	public static var FLUSH:UInt = 2;
	public static var SKIP:UInt = 3;
	
	private var background:FlxSprite;
	
	private var controller:RmzController;
	
	private var x:Float;
	private var y:Float;
	private var textObject:RmzText;
	private var finished:Bool;
	
	private var multipanel(default,set):Bool = false;
	private var typed:Bool = false;
	
	private var prematureAction:UInt;
	
	private var finishCallback:Dynamic;
	private var finishCallbackParams:Array<Dynamic>;
	
	/**
	 * 
	 * @param	content
	 * @param	type
	 */
	public function new( x:Float, y:Float, content:String, multipanel:Bool = false, typed:Bool = false ) {
		this.x = x;
		this.y = y;
		
		controller = new RmzController();
		
		//Initializing the text
		this.textObject = new RmzText( x, y, 100, content );
		this.multipanel = multipanel;
		this.typed = typed;
		textObject.setCompleteCallback( endPanel );
		
		//Setting default BG
		background = new FlxSprite(x, y);
		setBackgroundColor( 100, 32, 0, 0, 0xFF000000 );
		
		super();
		
		//Adding stuff to the group
		add(background);
		add(textObject);
	}
	
	override public function update():Void {
		controller.checkKeyPress();
		super.update();
	}
	
	public function setBackgroundColor( width:Int, height:Int, marginX:Int, marginY:Int, color:Int ):Void {
		background.makeGraphic(width, height, color);
		textObject.x = x + marginX;
		textObject.y = y + marginY;
		textObject.fieldWidth = width - 2 * marginY;
	}
	
	public function set_multipanel(value):Bool {
		textObject.cursorCharacter = ">";
		textObject.cursorBlinkSpeed = 0.8;
		return multipanel = value;
	}
	
	public function setMultipanelKey( key:Int, prematureAction:UInt = 0 ) {
		controller.bindJustPressed( key, callNextPanel );
		this.prematureAction = prematureAction;
	}
	
	public function setFinishCallback( callback:Dynamic, ?params:Array<Dynamic> ) {
		finishCallback = callback;
		finishCallbackParams = params;
	}
	
	public function display():Void {
		revive();
		textObject.start();
		if (!typed) {
			textObject.skip();
		}
	}
	
	private function endPanel():Void {
		if (multipanel)
			textObject.showCursor = true;
		//if this is the last panel
			finished = true;
	}
	
	override public function kill():Void {
		textObject;
		if ( finishCallback != null ) {
			Reflect.callMethod( { }, finishCallback, finishCallbackParams );
		}
		super.kill();
	}
	
	private function callNextPanel():Void {
		if (finished)
			kill();
		else {
			switch(prematureAction) {
				case RmzTextBox.HURRY: textObject.delay = 0.01;
				case RmzTextBox.FLUSH: textObject.skip();
				//case SKIP: display next panel somehow
			}
		}
	}
	
}