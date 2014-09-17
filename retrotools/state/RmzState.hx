package retrotools.state;

// Core Flixel Imports
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;

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
	
	// Groups containing all the included objects, for easier sorting
	private var objectGroup:FlxTypedGroup<FlxObject>;
	private var mapGroup:FlxGroup;
	
	private var paused:Bool;
	private var pauseHandler:FlxBasic;
	private var pauseSource:String;
	
	private var player:FlxSprite;

	public function new() {
		super();
		groupMap = new Map();
		tilemapMap = new Map();
		
		controller = new RmzController();
		pauseController = new RmzController();
		
		mapGroup = new FlxGroup();
		add( mapGroup );
		
		objectGroup = new FlxTypedGroup();
		add( objectGroup );
		
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
	
	public function pause( pauseHandler:FlxBasic = null, pauseSource:String ):Void {
		if ( pauseHandler != null ) {
			this.pauseHandler = pauseHandler;
		} else if ( this.pauseHandler == null ) {
			throw "Can't pause if there is no pauseHandler.";
		}
		paused = true;
		this.pauseSource = pauseSource;
		add( pauseHandler );
	}
	
	public function unpause( pauseSource:String ):Void {
		if ( paused && this.pauseSource == pauseSource ) {
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
			//add( group );
			addGroup( group );
		}
		
		if ( addColliders ) {
			for ( member in group.members ) {
				if ( Std.is( member, RmzActor ) ) {
					for ( mem in cast( member, RmzActor ).getColliderGroup().members ) {
						objectGroup.add( cast( mem, FlxObject ) );
					}
				}
			}
		}
	}
	
	private function addGroup( group:FlxGroup ) {
		for ( mem in group.members ) {
			if ( Std.is( mem, FlxObject ) ) {
				objectGroup.add( cast( mem, FlxObject ) );
			} else if ( Std.is( mem, FlxGroup ) ) {
				addGroup( cast( mem, FlxGroup ) );
			}
		}
	}
	
	public function includeTilemap( tilemap:FlxTilemap, name:String, addNow:Bool = true ):Void {
		tilemapMap.set( name, tilemap );
		if ( addNow )
			mapGroup.add( tilemap );
	}
	
	public function getGroup( name:String ):FlxGroup {
		return groupMap.get( name );
	}
	
	public function getTilemap( name:String ):FlxTilemap {
		return tilemapMap.get( name );
	}
	
}