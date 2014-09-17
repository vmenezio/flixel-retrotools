package retrotools.sprites;

// Core Flixel Imports
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;

/**
 * The <b>RmzCollider</b> class offers a foundation for simple objects that must respond to
 * collisions, such as hitboxes, bullets or collectibles.
 * 
 * @author Vinícius Menézio
 */
class RmzCollider extends FlxSprite
{
	
	// TODO: Make it possible to chose between 'collide' and 'overlap'.
	
	private var collidingGroup:FlxGroup;
	private var CollidingClass:Class<FlxObject>;
	public var colliding:Bool = false;
	
	private var attachedObject:FlxObject;
	private var attachmentOffset:FlxPoint;
	private var attached:Bool = false;
	
	private var timer:FlxTimer;

	/**
	 * Creates a new <b>RmzCollider</b> from the <b>FlxState</b> where it will act and the <b>Class</b> it will collide with.
	 * 
	 * @param	collidingState		<b>FlxState</b> from where the <b>RmzCollider</b> will draw candidates for it's collision checks.
	 * @param	CollidingClass		<b>Class<FlxObject></b> the <b>RmzCollider</b> must succesfully collide with.
	 */
	public function new(collidingGroup:FlxGroup, CollidingClass:Class<FlxObject>) {
		super(0, 0);
		kill();
		attachmentOffset = new FlxPoint();
		timer = new FlxTimer();
		this.collidingGroup = collidingGroup;
		this.CollidingClass = CollidingClass;
	}
	
	override public function update():Void {
		colliding = false;
		if ( attached ) {
			this.x = attachedObject.x + attachmentOffset.x;
			this.y = attachedObject.y + attachmentOffset.y;
		}
		super.update();
		FlxG.overlap(this, collidingGroup, verifyCollision);
	}
	
	/**
	 * Defines the values for the horizontal and vertical attachment offsets.
	 * 
	 * @param	offsetX		<b>Float</b> representing the x coordinate of the attachment offset.
	 * @param	offsetY		<b>Float</b> representing the x coordinate of the attachment offset.
	 */
	public function setAttachmentOffset( offsetX:Float, offsetY:Float ):Void {
		attachmentOffset.x = offsetX;
		attachmentOffset.y = offsetY;
	}
	
	/**
	 * Checks whether a collision with a valid object has been made, and calls the onHit() method if it has.
	 * 
	 * @param	self		<b>FlxObject</b> representing the <b>RmzCollider</b> itself.
	 * @param	target		<b>FlxObject</b> representing the object the <b>RmzCollider</b> has hit.
	 */
	private function verifyCollision(self:FlxObject, target:FlxObject):Void {
		if ( Std.is( target, CollidingClass ) && alive ) {
			onHit( target );
			colliding = true;
		}
	}
	
	/**
	 * Executes an action once a valid collision has been made.
	 * 
	 * @param	target		<b>FlxObject</b> representing the object the <b>RmzCollider</b> has hit
	 */
	public function onHit(target:FlxObject):Void {
		trace("collision detected.");
	}
	
	/**
	 * Activates the <b>RmzCollider</b> at a specified position, and gives it a specified lifespan.
	 * 
	 * @param	x			<b>Float</b> representing the x coordinate of the activation position.
	 * @param	y			<b>Float</b> representing the y coordinate of the activation position.
	 * @param	lifespan	<b>Float</b> representing the time in seconds the <b>RmzCollider</b> must remain active. 
	 * If assigned to a value of zero or less, the <b>RmzCollider</b> remains active until it's killed externally.
	 */
	public function activate( x:Float = 0, y:Float = 0, lifespan:Float = -1  ) {
		if ( attached ) {
			x += attachedObject.x + attachmentOffset.x;
			y += attachedObject.y + attachmentOffset.x;
		}
		this.x = x;
		this.y = y;
		if ( lifespan > 0 )
			timer.start( lifespan, timeOut, 1 );
		revive();
	}
	
	/**
	 * Links the <b>RmzCollider</b>'s position to that of a target <b>FlxObject</b>.
	 * 
	 * @param	target		<b>FlxObject</b> the <b>RmzCollider</b> will attach itself to.
	 * @param	offsetX		<b>Float</b> representing the horizontal offset from the target's position and the <b>RmzCollider</b>'s
	 * @param	offsetY		<b>Float</b> representing the vertical offset from the target's position and the <b>RmzCollider</b>'s
	 */
	public function attach( target:FlxObject, offsetX:Float=0, offsetY:Float=0 ):Void {
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