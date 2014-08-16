package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxDestroyUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _player:Player;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_player = new Player(20, 20);
		add(_player);
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
	}	
}