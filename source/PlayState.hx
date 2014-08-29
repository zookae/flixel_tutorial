package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.group.FlxTypedGroup;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _player:Player;
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _grpCoins:FlxTypedGroup<Coin>;
	private var _grpEnemies:FlxTypedGroup<Enemy>;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_map = new FlxOgmoLoader("assets/data/room-001.oel");
		_mWalls = _map.loadTilemap("assets/images/tiles.png", 16, 16, "walls");
		_mWalls.setTileProperties(1, FlxObject.NONE); // tile 1 has no collision
		_mWalls.setTileProperties(2, FlxObject.ANY); // tile 2 collides w/anything
		add(_mWalls);

		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);

		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);

		_player = new Player();
		_map.loadEntities(placeEntities, "entities"); // call "placeEntities" fn on all maps in "entitities layer"
		add(_player);

		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN, 1);

		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_player = FlxDestroyUtil.destroy(_player);
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

		FlxG.collide(_player, _mWalls);
		FlxG.overlap(_player, _grpCoins, playerTouchCoin);
	}

	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));

		// special logic to place player
		if (entityName == "player") {
			_player.x = x;
			_player.y = y;
		} 
		else if (entityName == "coin") {
			_grpCoins.add(new Coin(x+4, y+4));
		}
		else if (entityName == "enemy") {
			_grpEnemies.add(new Enemy(x+ 4, y, Std.parseInt(entityData.get("etype"))));
		}
	}

	private function playerTouchCoin(P:Player, C:Coin):Void {
		if (P.alive && P.exists && C.alive && C.exists) {
			C.kill();
		}
	}
}