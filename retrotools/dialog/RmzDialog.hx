package retrotools.dialog;

import flixel.group.FlxGroup;
import flixel.FlxSprite;

import retrotools.controller.RmzController;

/**
 * ...
 * @author ...
 */
class RmzDialog extends FlxGroup
{
	
	private var background:FlxSprite;
	private var controller:RmzController;
	
	private var x:Float;
	private var y:Float;
	
	private var height:Int;
	private var width:Int;

	public function new( x:Float, y:Float ) {
		super();
		
		this.x = x;
		this.y = y;
		
		controller = new RmzController();
		background = new FlxSprite(x, y);
		
		add(background);
	}
	
	public function setBackgroundColor( color:Int, width:Int=1, height:Int=1 ):Void {
		this.width = width;
		this.height = height;
		background.makeGraphic( width, height, color );
	}
	
	override public function update():Void {
		super.update();
		controller.checkKeyPress();
	}
	
}