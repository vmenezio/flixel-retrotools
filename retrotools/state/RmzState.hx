package retrotools.state;

// Core Flixel Imports
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

// Retrotools Imports
import retrotools.controller.RmzController;
import retrotools.sprites.RmzActor;

/**
 * The <b>RmzState</b> class expands the functionaly of <b>FlxState</b>s, so that
 * states can be written with less redundant code, and integrate more easily with 
 * features from the rest of the retrotools.
 * 
 * @author Vinícius Menézio
 */
class RmzState extends FlxState
{
	
	// Maps for easily managing FlxGroups and FlxTilemaps
	private var groupMap:Map<String,FlxGroup>;
	private var tilemapMap:Map<String,FlxTilemap>;
	
	// Controllers for the paused and unpaused states
	private var controller:RmzController;
	private var pauseController:RmzController;
	
	private var paused:Bool;
	private var pauseHandler:FlxBasic;
	
	private var player:FlxSprite;

	public function new() {
		super();
		groupMap = new Map();
		tilemapMap = new Map();
		
		controller = new RmzController();
		pauseController = new RmzController();
		
		paused = false;
	}
	
	override public function update():Void {
		if ( paused ) {
			pausedUpdate();
		} else {
			super.update();
			controller.checkKeyPress();
		}
	}
	
	private function pausedUpdate() {
		pauseHandler.update();
		pauseController.checkKeyPress();
	}
	
	public function pause( pauseHandler:FlxBasic = null ):Void {
		if ( pauseHandler != null ) {
			this.pauseHandler = pauseHandler;
		} else if ( this.pauseHandler == null ) {
			throw "Can't pause if there is no pauseHandler.";
		}
		paused = true;
		add( pauseHandler );
	}
	
	public function unpause():Void {
		if ( paused ) {
			paused = false;
			remove( pauseHandler );
		}
	}
	
	public function setPlayer( player:FlxSprite ):Void {
		this.player = player;
	}
	
	public function getPlayer():FlxSprite {
		return player;
	}
	
	public function includeGroup( group:FlxGroup, name:String, addNow:Bool = true , addColliders:Bool = true ):Void {
		groupMap.set( name, group );
		if ( addNow ) {
			add( group );
		}
		
		if ( addColliders ) {
			for ( member in group.members ) {
				if ( Std.is( member, RmzActor ) ) {
					group.add( cast( member, RmzActor ).getColliderGroup() ) ;
				}
			}
		}
	}
	
	public function includeTilemap( tilemap:FlxTilemap, name:String, addNow:Bool = true ):Void {
		tilemapMap.set( name, tilemap );
		if ( addNow )
			add( tilemap );
	}
	
	public function getGroup( name:String ):FlxGroup {
		return groupMap.get( name );
	}
	
	public function getTilemap( name:String ):FlxTilemap {
		return tilemapMap.get( name );
	}
	
}