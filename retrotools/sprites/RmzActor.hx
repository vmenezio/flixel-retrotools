package retrotools.sprites;

// Core Flixel Imports
import flixel.FlxSprite;
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
	public static inline var RANDOM:UInt	= 0x10000;
	
	private var movementSpeed:FlxPoint;
	private var movementDirection:UInt = 0x00000;
	private var movementAcceleration:FlxPoint;
	private var acceleratedMovementDirection:UInt = 0x00000;
	
	private var controller:RmzController;

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
	}
	
	/**
	 * Called at each step to update the state of this object.
	 */
	override public function update():Void {
		controller.checkKeyPress();
		setVelocity();
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
	 * 
	 * @param	x			<b>Float</b> representing the x component of the drag.
	 * @param	y			<b>Float</b> representing the y component of the drag.
	 */
	public function setDrag( x:Float, y:Float ) {
		drag.set(x, y);
	}
	
	/**
	 * Defines the acceleration imposed on the <b>RmzActor</b> at all times. Useful for setting gravity.
	 * 
	 * @param	x			<b>Float</b> representing the x component of the acceleration.
	 * @param	y			<b>Float</b> representing the y component of the acceleration.
	 */
	public function setAcceleration( x:Float, y:Float ) {
		acceleration.set(x, y);
	}
	
	/**
	 * Defines the max velocity the <b>RmzActor</b> can achieve while accelerating.
	 * 
	 * @param	x			<b>Float</b> representing the max velocity in the x direction
	 * @param	y			<b>Float</b> representing the max velocity in the y direction
	 */
	public function setMaxVelocity( x:Float, y:Float ) {
		maxVelocity.set(x, y);
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
			
		if ( drag.x < 0 && ( ( movementDirection & RIGHT ) | ( movementDirection & LEFT ) ) == NONE
			&& ( ( acceleratedMovementDirection & RIGHT ) | ( acceleratedMovementDirection & LEFT ) ) == NONE )
			velocity.x = 0;
		if ( drag.y < 0 && ( ( movementDirection & UP ) | ( movementDirection & DOWN ) ) == NONE
			&& ( ( acceleratedMovementDirection & UP ) | ( acceleratedMovementDirection & DOWN ) ) == NONE )
			velocity.y = 0;
	}
	
	/**
	 * Called at each step to reset the direction of the <b>RmzActor</b>.
	 */
	private function resetDirection() {
		movementDirection = 0x00000;
		acceleratedMovementDirection = 0x00000;
	}
	
}