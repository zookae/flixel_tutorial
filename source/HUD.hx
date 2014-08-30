package ;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;


class HUD extends FlxTypedGroup<FlxSprite> {
	// extend a FlxTypedGroup to hold multiple UI elements

	private var _sprBack:FlxSprite;
	private var _txtHealth:FlxText;
	private var _txtMoney:FlxText;
	private var _sprHealth:FlxSprite;
	private var _sprMoney:FlxSprite;

	public function new() {
		super();

		// set black background with white rectangle
		_sprBack = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		_sprBack.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);

		// display health in gray as "N / M"
		_txtHealth = new FlxText(16, 2, 0, "3 / 3", 8);
		_txtHealth.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);

		// display money in gray
		_txtMoney = new FlxText(0, 2, 0, "0", 8);
		_txtMoney.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
		_txtMoney.alignment = "right"; // money text is aligned right

		_sprHealth = new FlxSprite(4, _txtHealth.y + (_txtHealth.height/2) - 4, "assets/images/health.png");
		_sprMoney = new FlxSprite(FlxG.width - 12, _txtMoney.y + (_txtMoney.height/2) - 4, "assets/images/coin.png");

		_txtMoney.x = _sprMoney.x - _txtMoney.width - 4; // x offset to 4 from end

		add(_sprBack);
		add(_txtHealth);
		add(_txtMoney);
		add(_sprMoney);
		add(_sprHealth);

		// set all to have fixed position on screen, regardless of camera scroll
		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
		});
	}


	public function updateHUD(Health:Int=0, Money:Int=0):Void {
		_txtHealth.text = Std.string(Health) + " / 3";
		_txtMoney.text = Std.string(Money);
		_txtMoney.x = _sprMoney.x - _txtMoney.width - 4;
	}
}