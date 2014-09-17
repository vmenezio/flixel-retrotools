package retrotools.sprites;

// Core Flixel Imports
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxPoint;
import flixel.FlxObject;

// Retrotools Imports
import retrotools.controller.RmzController;

/**
 * The <b>RmzActor</b> class expands the functionaly of the <b>FlxSprite</b> making it 
 * easier to create sprites meant to move around the screen, interact with other objects and 
 * respond to keyboard controls.
 * 
 * @author Vinícius Menézio
 */
class RmzActor extends FlxSprite {
	
	public static inline var NONE:UInt		= 0x00000;
	
	public static inline var LEFT:UInt		= 0x00001;
	public static inline var RIGHT:UInt		= 0x00010;
	public static inline var UP:UInt		= 0x00100;
	public static inline var DOWN:UInt		= 0x01000;
	
	public static inline var UPPER_LEFT:UInt		= 0x00101;
	public static inline var UPPER_RIGHT:UInt		= 0x00110;
	public static inline var LOWER_LEFT:UInt		= 0x01001;
	public static inline var LOWER_RIGHT:UInt		= 0x01010;
	
	public static inline var RANDOM:UInt	= 0x10000;
	
	private var movementSpeed:FlxPoint;
	private var movementDirection:UInt = 0x00000;
	private var movementAcceleration:FlxPoint;
	private var acceleratedMovementDirection:UInt = 0x00000;
	
	private var controller:RmzController;
	private var colliderGroup:FlxGroup;
	private var colliderMap:Map<String,RmzCollider>;

	/**
	 * Creates a <b>RmzActor</b> at a specified position with a specified one-frame graphic. 
	 * If none is provided, a 16x16 image of the HaxeFlixel logo is used.
	 * 
	 * @param	x				<b>Float</b> specifying the initial x coordinate of the sprite.
	 * @param	x				<b>Float</b> specifying the initial y coordinate of the sprite.
	 * @param	simpleGraphic	<b>Dynamic</b> The graphic you want to display.
	 */
	public function new(x:Float=0, y:Float=0, ?simpleGraphic:Dynamic) {
		super(x, y, simpleGraphic);
		
		controller = new RmzController();
		movementSpeed = new FlxPoint();
		movementAcceleration = new FlxPoint();
		
		setDrag(500, 500);
		setMaxVelocity(100, 100); 
		
		colliderGroup = new FlxGroup();
		colliderMap = new Map();
	}
	
	/**
	 * Called at each step to update the state of this object.
	 */
	override public function update():Void {
		controller.checkKeyPress();
		setVelocity();
		setFacingDirection();
		resetDirection();
		
		super.update();
	}
	
	/**
	 * Moves the <b>RmzActor</b> linearly towards the specified direction with the specified speed.
	 * 
	 * @param	direction		<b>Uint</b> representing the direction of the movement.
	 * @param	speed			<b>Float</b> representing the speed of the movement.
	 */
	public function move( direction:UInt, speed:Float ):Void {
		movementDirection = ( movementDirection | direction );
		
		if ( ( direction & ( RIGHT | LEFT ) ) != 0 ) {
			movementSpeed.x = speed;
		}
		if ( ( direction & ( UP | DOWN ) ) != 0 ) {
			movementSpeed.y = speed;
		}
	}
	
	/**
	 * Accelerates the <b>RmzActor</b> towards the specified direction with the specified rate.
	 * 
	 * @param	direction		<b>Uint</b> representing the direction of the movement.
	 * @param	rate			<b>Float</b> representing the rate at which the speed of movement increases.
	 */
	public function accelerate( direction:UInt, rate:Float ):Void {
		acceleratedMovementDirection = ( acceleratedMovementDirection | direction );
		
		if ( ( direction & ( RIGHT | LEFT ) ) != 0 ) {
			movementAcceleration.x = rate;
		}
		if ( ( direction & ( UP | DOWN ) ) != 0 ) {
			movementAcceleration.y = rate;
		}
	}
	
	/**
	 * Defines the drag imposed on the <b>RmzActor</b> when it's not accelerating. 
	 * If set to a negative number, the <b>RmzActor</b> will stop as soon as it stops accelerating.
	 * 
	 * @param	x			<b>Float</b> representing the x component of the drag.
	 * @param	y			<b>Float</b> representing the y component of the drag.
	 */
	public function setDrag( x:Float, y:Float ):Void {
		drag.set(x, y);
	}
	
	/**
	 * Defines the acceleration imposed on the <b>RmzActor</b> at all times. Useful for setting gravity.
	 * 
	 * @param	x			<b>Float</b> representing the x component of the acceleration.
	 * @param	y			<b>Float</b> representing the y component of the acceleration.
	 */
	public function setAcceleration( x:Float, y:Float ):Void {
		acceleration.set(x, y);
	}
	
	/**
	 * Defines the max velocity the <b>RmzActor</b> can achieve while accelerating.
	 * 
	 * @param	x			<b>Float</b> representing the max velocity in the x direction
	 * @param	y			<b>Float</b> representing the max velocity in the y direction
	 */
	public function setMaxVelocity( x:Float, y:Float ):Void {
		maxVelocity.set(x, y);
	}
	
	/**
	 * Defines what portion of the <b>RmzActor</b>'s graphic should actually be taken into 
	 * account when calculating collisions.
	 * 
	 * @param	offsetX		<b>Float</b> representing the starting point of the hitbox, horizontally.
	 * @param	offsetY		<b>Float</b> representing the starting point of the hitbox, vertically.
	 * @param	width		<b>Float</b> representing the width of the hitbox.
	 * @param	height		<b>Float</b> representing the height of the hitbox.
	 */
	public function setHitbox( offsetX:Float, offsetY:Float, width:Float, height:Float ):Void {
		this.offset.set( offsetX, offsetY );
		this.setSize( width, height );
	}
	
	/**
	 * Called at each step to set the velocity of the <b>RmzActor</b>.
	 */
	private function setVelocity():Void {
		if ( ( (movementDirection & LEFT) != NONE ) && !( (movementDirection & RIGHT) != NONE ) )
			velocity.x = -movementSpeed.x;
		if ( ( (movementDirection & RIGHT) != NONE ) && !( (movementDirection & LEFT) != NONE ) )
			velocity.x = movementSpeed.x;
		if ( ( (movementDirection & UP) != NONE ) && !( (movementDirection & DOWN) != NONE ) )
			velocity.y = -movementSpeed.y;
		if ( ( (movementDirection & DOWN) != NONE ) && !( (movementDirection & UP) != NONE ) )
			velocity.y = movementSpeed.y;
			
		if ( ( (acceleratedMovementDirection & LEFT) != NONE ) && !( (acceleratedMovementDirection & RIGHT) != NONE ) )
			velocity.x += -movementAcceleration.x;
		if ( ( (acceleratedMovementDirection & RIGHT) != NONE ) && !( (acceleratedMovementDirection & LEFT) != NONE ) )
			velocity.x += movementAcceleration.x;
		if ( ( (acceleratedMovementDirection & UP) != NONE ) && !( (acceleratedMovementDirection & DOWN) != NONE ) )
			velocity.y += -movementAcceleration.y;
		if ( ( (acceleratedMovementDirection & DOWN) != NONE ) && !( (acceleratedMovementDirection & UP) != NONE ) )
			velocity.y += movementAcceleration.y;
			
		if ( drag.x < 0 && ( ( ( movementDirection & ( RIGHT | LEFT ) ) == NONE ) 
			 || ( ( ( movementDirection & RIGHT ) != NONE ) && ( ( movementDirection & LEFT ) != NONE ) ) )
			 && ( ( ( acceleratedMovementDirection & ( RIGHT | LEFT ) ) == NONE ) 
			 || ( ( ( acceleratedMovementDirection & RIGHT ) != NONE ) && ( ( acceleratedMovementDirection & LEFT ) != NONE ) ) ) )
			velocity.x = 0;
		if ( drag.y < 0 && ( ( ( movementDirection & ( UP | DOWN ) ) == NONE ) 
			 || ( ( ( movementDirection & UP ) != NONE ) && ( ( movementDirection & DOWN ) != NONE ) ) )
			 && ( ( ( acceleratedMovementDirection & ( UP | DOWN ) ) == NONE ) 
			 || ( ( ( acceleratedMovementDirection & UP ) != NONE ) && ( ( acceleratedMovementDirection & DOWN ) != NONE ) ) ) )
			velocity.y = 0;
	}
	
	/**
	 * Called at each step to set the facing direction of the <b>RmzActor</b>
	 */
	private function setFacingDirection():Void {
		if ( movementDirection == 0x00000 && acceleratedMovementDirection != 0x00000 )
			facing = acceleratedMovementDirection;
		else if ( movementDirection != 0x00000 )
			facing = movementDirection;
			
		if ( ( ( facing & RIGHT ) != NONE ) && ( ( facing & LEFT ) != NONE ) ) {
			facing -= ( RIGHT | LEFT );
		}
		
		if ( ( ( facing & UP ) != NONE ) && ( ( facing & DOWN ) != NONE ) ) {
			facing -= ( UP | DOWN );
		}
	}
	
	/**
	 * Called at each step to reset the direction of the <b>RmzActor</b>.
	 */
	private function resetDirection():Void {
		movementDirection = 0x00000;
		acceleratedMovementDirection = 0x00000;
	}
	
	/**
	 * Inserts a <b>RmzCollider</b> into the <b>RmzActor</b>'s internal colliderGroup, and associates
	 * it to the specified identifier in the internal colliderMap.
	 * 
	 * @param	identifier		<b>String</b> representing the key associated to the collider in the colliderMap.
	 * @param	collider		<b>RmzCollider</b> to be inserted into this <b>RmzActor</b>'s colliderGroup.
	 */
	private function addCollider( identifier:String, collider:RmzCollider ):Void {
		colliderMap.set( identifier, collider );
		colliderGroup.add( collider );
	}
	
	/**
	 * Returns the <b>RmzCollider</b> associated with the specified identifier, or null if none is found.
	 * 
	 * @param	identifier		<b>String</b> representing the key of the desired <b>RmzCollider</b>
	 * @return	A <b>RmzCollider</b> retrieved from the internal colliderMap.
	 */
	public function getCollider( identifier:String ):RmzCollider {
		return colliderMap.get( identifier );
	}
	
	/**
	 * Returns the internal colliderGroup.
	 * 
	 * @return	A <b>FlxGroup</b> containing the internal <b>RmzColliders<b>.
	 */
	public function getColliderGroup():FlxGroup {
		return colliderGroup;
	}
	
}