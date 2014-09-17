package retrotools.dialog;

// Core Flixel Imports
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import retrotools.controller.RmzGlobalKeys;
import retrotools.state.RmzState;

import retrotools.controller.RmzController;

/**
 * The <b>RmzTextBox</b> class speeds up the creation of text elements such as interfaces,
 * dialogue boxes, credits sequences, among others - allowing for background customizantion
 * and multiple panels of text.
 * 
 * @author Vinícius Menézio
 */
class RmzTextBox extends RmzDialog
{
	
	// TODO: Write documentation for this class
	// TODO: Support multiple panels
	
	public static var NONE:UInt = 0;
	public static var HURRY:UInt = 1;
	public static var FLUSH:UInt = 2;
	public static var SKIP:UInt = 3;
	
	private var textObject:RmzText;
	private var content:Array<Dynamic>;
	private var currentContent:Int = 0;
	
	private var innerPrompt:RmzPrompt;
	private var promptSpecs:Dynamic = {
		x:			0,
		y:			0,
		width:		16,
		height:		16,
		marginX:	0,
		marginY:	0,
		color:		0xFF000000
	};
	
	public var multipanel(default,set):Bool = false;
	
	private var finished:Bool;
	private var callbackList:Array<Dynamic>;
	private var callbackParamList:Array<Array<Dynamic>>;
	
	private var finishCallback:Dynamic;
	private var finishCallbackParams:Array<Dynamic>;
	
	private var prematureAction:UInt = NONE;
	
	private var skipFrame:Bool;
	
	public function new( x:Float, y:Float ) {
		
		super( x, y );
		
		//Initializing the text
		content = new Array();
		this.textObject = new RmzText( x, y, 100, "" );
		textObject.setCompleteCallback( endPanel );
		
		callbackList = new Array();
		callbackParamList = new Array();
		
		loadPresetKeys();
		
		//Adding stuff to the group
		add(textObject);
	}
	
	override public function update():Void {
		if ( innerPrompt != null && innerPrompt.alive ) {
			skipFrame = true;
			innerPrompt.update();
			var response = innerPrompt.getResponse();
			if ( response != "" ) {
				remove( innerPrompt );
				start( content[currentContent].map.get(response) );
			}
		}
		if (skipFrame) {
			skipFrame = false;
			return;
		}
		super.update();
	}
	
	public function setLayout( width:Int, height:Int, marginX:Int, marginY:Int, maxLines:Int, color:Int ):Void {
		textObject.x = x + marginX;
		textObject.y = y + marginY;
		textObject.fieldWidth = width - 2 * marginX;
		textObject.setMaxLines( maxLines );
		setBackgroundColor( color, width, height );
	}
	
	public function setPromptLayout( x:Int, y:Int, width:Int, height:Int, marginX:Int, marginY:Int, color:Int ):Void {
		promptSpecs.x = x;
		promptSpecs.y = y;
		promptSpecs.width = width;
		promptSpecs.height = height;
		promptSpecs.marginX = marginX;
		promptSpecs.marginY = marginY;
		promptSpecs.color = color;
	}
	
	public function start( currentContent ):Void {
		this.currentContent = currentContent;
		if ( content[currentContent].text.length == 0 )
			throw "Can't start RmzTextBox if there's no content.";
		textObject.resetText( content[currentContent].text );
		display();
	}
	
	public function addIntermediateContent( text:String, contentMap:Map<String,Int> ):Void {
		content.push( { text:text, map:contentMap } );
		var prompt = new RmzPrompt( promptSpecs.x, promptSpecs.y );
		prompt.setLayout( promptSpecs.width, promptSpecs.height, promptSpecs.marginX, promptSpecs.marginY, promptSpecs.color );
		for ( item in contentMap.keys() )
			prompt.addOption( item, item );
		addCallback( addPrompt, [prompt] );
	}
	
	public function addFinalContent( text:String ):Void {
		content.push( { text:text } );
		addCallback( null, null );
	}
	
	private function display():Void {
		finished = false;
		skipFrame = true;
		revive();
		textObject.start(0.05, true);
	}
	
	public function setConfirmKeys( key:Array<Int>, prematureAction:UInt = 0 ) {
		controller = new RmzController();
		controller.bindJustPressed( key, callNextPanel );
		this.prematureAction = prematureAction;
	}
	
	public function setConfirmGamepadButton( button:Array<Int>, gamepadID:Int, prematureAction:UInt = 0 ) {
		controller = new RmzController();
		controller.bindGamepadJustPressed( button, gamepadID, callNextPanel );
		this.prematureAction = prematureAction;
	}
	
	public function addCallback( callback:Dynamic, ?params:Array<Dynamic> ) {
		callbackList.push(callback);
		callbackParamList.push(params);
	}
	
	public function setFinishCallback( callback:Dynamic, ?params:Array<Dynamic> ) {
		finishCallback = callback;
		finishCallbackParams = params;
	}
	
	public function set_multipanel(value):Bool {
		textObject.cursorCharacter = ">";
		textObject.cursorBlinkSpeed = 0.8;
		return multipanel = value;
	}
	
	public function addPrompt( prompt:RmzPrompt ) {
		innerPrompt = prompt.activate();
		super.add( prompt );
	}
	
	override public function revive():Void {
		super.revive();
		callAll( "revive" );
		finished = false;
		textObject.showCursor = false;
	}
	
	override public function add(object:FlxBasic):FlxBasic {
		if ( Std.is ( object, RmzPrompt ) )
			throw "RmzPrompts should be added through the addPrompt() method";
		return super.add(object);
	}
	
	private function callNextPanel():Void {
		if ( textObject.getNextText() == "" && finished ) {
			endTextBox();
		} else if ( !finished ) {
			switch( prematureAction ) {
				case RmzTextBox.HURRY: textObject.delay = 0.01;
				case RmzTextBox.FLUSH: textObject.skip();
				//case SKIP: display next panel somehow
			}
		} else {
			textObject.resetText( textObject.getNextText() );
			display();
		}
	}
	
	private function endPanel():Void {
		if (multipanel)
			textObject.showCursor = true;
		finished = true;
	}
	
	private function endTextBox():Void {
		if ( callbackList[currentContent] == null )
			Reflect.callMethod( null, finishCallback, finishCallbackParams );
		else
			Reflect.callMethod( null, callbackList[currentContent], callbackParamList[currentContent] );
	}
	
	public function loadPresetKeys():Void {
		controller = new RmzController();
		switch ( RmzGlobalKeys.MODE ) {
			case RmzGlobalKeys.KEYBOARD: 
				setConfirmKeys( RmzGlobalKeys.PRIMARY );
			case RmzGlobalKeys.GAMEPAD: 
				setConfirmGamepadButton( RmzGlobalKeys.PRIMARY, 0 );
		}
	}
	
}