package retrotools.sprites;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Vinícius Menézio
 */
class RmzCollider extends FlxSprite
{
	
	private var collidingState:FlxState;
	private var CollidingClass:Class<FlxObject>;
	
	private var attachedObject:FlxObject;
	private var attached:Bool = false;
	private var attachmentOffset:FlxPoint;
	
	private var timer:FlxTimer;

	public function new(collidingState:FlxState, CollidingClass:Class<FlxObject>) {
		super(0, 0);
		kill();
		attachmentOffset = new FlxPoint();
		timer = new FlxTimer();
		this.collidingState = collidingState;
		this.CollidingClass = CollidingClass;
	}
	
	override public function update():Void {
		FlxG.overlap(this, collidingState, verifyCollision);
		if ( attached ) {
			this.x = attachedObject.x + attachmentOffset.x;
			this.y = attachedObject.y + attachmentOffset.y;
		}
		super.update();
	}
	
	private function verifyCollision(self:FlxObject, other:FlxObject):Void {
		if ( Std.is( other, CollidingClass ) )
			onHit( other );
	}
	
	public function onHit(other:FlxObject):Void {
		trace("collision detected.");
	}
	
	public function activate( x:Float, y:Float, lifespan:Float ) {
		revive();
		this.x = x;
		this.y = y;
		if ( lifespan > 0 )
			timer.start( lifespan, timeOut, 1 );
	}
	
	public function attach( target:FlxObject, offsetX:Float, offsetY:Float ):Void {
		this.attachedObject = target;
		attachmentOffset.x = offsetX;
		attachmentOffset.y = offsetY;
		attached = true;
	}
	
	private function timeOut( timer:FlxTimer ) {
		kill();
	}
	
}