package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;

class GameOverState extends FlxState {
	private var _score:Int = 0;
	private var _win:Bool;
	private var _txtTitle:FlxText;
	private var _txtMessage:FlxText;
	private var _sprScore:FlxSprite;
	private var _txtScore:FlxText;
	private var _txtHiScore:FlxText;
	private var _btnMainMenu:FlxButton;

	public function new(Win:Bool, Score:Int) {
		super();
		_win = Win;
		_score = Score;
	}

	override public function create():Void {
		_txtTitle = new FlxText(0, 20, 0, _win ? "You Win!" : "Game Over :(", 22);
		_txtTitle.alignment = "center";
		_txtTitle.screenCenter(true, false);
		add(_txtTitle);

		_txtMessage = new FlxText(0, (FlxG.height/2) - 18, 0, "Final Score:", 8);
		_txtMessage.alignment = "center";
		_txtMessage.screenCenter(true, false);
		add(_txtMessage);

		_sprScore = new FlxSprite((FlxG.width/2) - 8, 0, "assets/images/coin.png");
		_sprScore.screenCenter(false, true);
		add(_sprScore);

		_txtScore = new FlxText((FlxG.width/2), 0, 0, Std.string(_score), 8);
		_txtScore.screenCenter(false, true);
		add(_txtScore);

		var _hiScore = checkHiScore(_score);

		_txtHiScore = new FlxText(0, (FlxG.height/2)+10, 0, "High Score: " + Std.string(_hiScore), 8);
		_txtHiScore.alignment = "center";
		_txtHiScore.screenCenter(true, false);
		add(_txtHiScore);

		_btnMainMenu = new FlxButton(0, FlxG.height-32, "Main Menu", goMainMenu);
		_btnMainMenu.screenCenter(true, false);
		_btnMainMenu.onUp.sound = FlxG.sound.load("assets/sounds/select.wav");
		add(_btnMainMenu);

		super.create();
	}

	override public function destroy():Void {
		super.destroy();

		_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		_txtMessage = FlxDestroyUtil.destroy(_txtMessage);
		_sprScore = FlxDestroyUtil.destroy(_sprScore);
		_txtScore = FlxDestroyUtil.destroy(_txtScore);
		//_txtHiScore = FlxDestroyUtil.destroy(_txtHiScore);
		_btnMainMenu = FlxDestroyUtil.destroy(_btnMainMenu);
	}

	private function checkHiScore(Score:Int):Int {
		var _hi:Int = Score;
		var _save:FlxSave = new FlxSave();
		if (_save.bind("flixel-tutorial")) {
			if(_save.data.hiscore != null) {
				if (_save.data.hiscore > _hi) {
					_hi = _save.data.hiscore;
				}
				else {
					_save.data.hiscore = _hi;
				}
			}
		}
		_save.close();
		return _hi;
	}

	private function goMainMenu():Void {
		FlxG.camera.fade(FlxColor.BLACK, 0.66, false, function() {
			FlxG.switchState(new MenuState());
		});
	}
}