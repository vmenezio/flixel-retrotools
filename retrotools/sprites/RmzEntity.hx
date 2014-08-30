package retrotools.sprites;

// Core Flixel Imports
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;
import flixel.FlxObject;
import flixel.FlxG;

// Retrotools Imports
import retrotools.controller.RmzController;

/**
 * The <b>RmzEntity</b> class expands the functionaly of the <b>FlxSprite</b> making it 
 * easier to create sprites meant to move around the screen, interact with other objects and 
 * respond to keyboard controls.
 * 
 * @author Vinícius Menézio
 */
class RmzEntity extends FlxSprite {
	private static var groups:Map<String, FlxTypedGroup<Dynamic>> = new Map<String, FlxTypedGroup<Dynamic>>();
	
	/**
	 * Creates a <b>RmzEntity</b> at a specified position with a specified one-frame graphic. 
	 * If none is provided, a 16x16 image of the HaxeFlixel logo is used.
	 * 
	 * @param	x				<b>Float</b> specifying the initial x coordinate of the sprite.
	 * @param	x				<b>Float</b> specifying the initial y coordinate of the sprite.
	 * @param	simpleGraphic	<b>Dynamic</b> The graphic you want to display.
	 */
	private function new(x:Float=0, y:Float=0, ?simpleGraphic:Dynamic) {
		super(x, y, simpleGraphic);
		
		addGroup();
	}
	
	/**
	 * Called at each step to update the state of this object.
	 */
	override public function update():Void {
		checkCollision();
		
		super.update();
	}
	
	/**
	 * Check if there is some <b>RmzEntity</b> colliding with the current <b>RmzEntity</b>.
	 */
	public function checkCollision():Void {
		if(!immovable) {
			FlxG.collide(this, cast(FlxG.state, PlayState).collideables);
		}
		
		for ( group in groups ) {
			if ( collidesWith(group.getFirstExisting()) ) {
				if (FlxG.collide(this, group)) {
					onCollide();
				}
			} else if ( overlapsWith(group.getFirstExisting()) ) {
				if (FlxG.overlap(this, group)) {
					onOverlap();
				}
			}
		}
	}
	
	/**
	 * This functions is used to evaluate what kind of <b>RmzEntity</b> could collide with the current <b>RmzEntity</b>.
	 * Override this function if necessary to include more validations.
	 * 
	 * @param	entity			<b>RmzEntity</b> representing the entity that is colliding with the current <b>RmzEntity</b>.
	 */
	private function collidesWith(entity:RmzEntity):Bool {
		return this != entity;
	}
	
	/**
	 * This functions is used to evaluate what kind of <b>RmzEntity</b> could overlap with the current <b>RmzEntity</b>.
	 * Override this function if necessary to include more validations.
	 * 
	 * @param	actor			<b>RmzEntity</b> representing the entity that is overlaping with the current <b>RmzEntity</b>.
	 */
	private function overlapsWith(entity:RmzEntity):Bool {
		return this != entity;
	}
	
	/**
	 * Function called when one <b>RmzEntity</b> collide with another <b>RmzEntity</b>.
	 * Is required to override this function to do some action when the <b>RmzEntity</b> collide with another.
	 * 
	 * @param	entity			<b>RmzEntity</b> representing the entity that is colliding with the current <b>RmzEntity</b>.
	 */
	private function onCollide():Void { }
	
	/**
	 * Function called when one <b>RmzEntity</b> overlap with another <b>RmzEntity</b>.
	 * Is required to override this function to do some action when the <b>RmzEntity</b> overlap with another.
	 * 
	 * @param	entity			<b>RmzEntity</b> representing the entity that is overlaping with the current <b>RmzEntity</b>.
	 */
	private function onOverlap():Void { }
	
	private function addGroup():Void {
		var group:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
		if (groups.exists(Type.getClassName(Type.getClass(this)))) {
			group = groups.get(Type.getClassName(Type.getClass(this)));
		}
		group.add(this);
		groups.set(Type.getClassName(Type.getClass(this)), group);
	}
	
	public function containsInstanceAlive(entityType:Class<Dynamic>):Bool {
		var type:String = Type.getClassName(entityType);
		return groups.exists(type) ? groups.get(type).countDead() != groups.get(type).length : false;
	}
}