package retrotools.sprites;

import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;

/**
 * ...
 * @author ...
 */
class RmzSensor extends RmzEntity
{
	private var attachedObject:FlxObject;
	private var attached:Bool = false;
	private var attachmentOffset:FlxPoint;
	
	private var timer:FlxTimer;

	private function new(x:Float=0, y:Float=0, ?simpleGraphic:Dynamic) {
		super(x, y, simpleGraphic);
		kill();
		attachmentOffset = new FlxPoint();
		timer = new FlxTimer();
	}
	
	override public function update():Void 
	{
		if ( attached ) {
			this.x = attachedObject.x + attachmentOffset.x;
			this.y = attachedObject.y + attachmentOffset.y;
		}
		
		super.update();
	}
	
	public function activete( x:Float = 0, y:Float = 0, lifespan:Float = -1  ):Void {
		revive();
		if ( attached ) {
			x += attachedObject.x + attachmentOffset.x;
			y += attachedObject.y + attachmentOffset.x;
		}
		this.x = x;
		this.y = y;
		if ( lifespan > 0 )
			timer.start( lifespan, timeOut, 1 );
	}
	
	/**
	 * Links the <b>RmzCollider</b>'s position to that of a target <b>FlxObject</b>.
	 * 
	 * @param	target		<b>FlxObject</b> the <b>RmzCollider</b> will attach itself to.
	 * @param	offsetX		<b>Float</b> representing the horizontal offset from the target's position and the <b>RmzCollider</b>'s
	 * @param	offsetY		<b>Float</b> representing the vertical offset from the target's position and the <b>RmzCollider</b>'s
	 */
	public function attach( target:FlxObject, offsetX:Float, offsetY:Float ):Void {
		this.attachedObject = target;
		attachmentOffset.x = offsetX;
		attachmentOffset.y = offsetY;
		attached = true;
	}
	
	/**
	 * Releases the <b>RmzCollider</b> from the <b>FlxObject</b> it's been attached to.
	 */
	public function detach():Void {
		this.attachedObject = null;
		this.attached = false;
	}
	
	/**
	 * Kills the <b>RmzCollider</b> once its lifespan is up.
	 * 
	 * @param	timer		<b>FlxTimer</b> controlling the <b>RmzCollide</b>'s lifespan.
	 */
	private function timeOut( timer:FlxTimer ) {
		kill();
	}
}