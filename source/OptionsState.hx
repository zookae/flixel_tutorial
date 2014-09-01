package ;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;

class OptionsState extends FlxState {
	private var _txtTitle:FlxText;
	private var _barVolume:FlxBar;
	private var _txtVolume:FlxText;
	private var _txtVolumeAmt:FlxText;
	private var _btnVolumeDown:FlxButton;
	private var _btnVolumeUp:FlxButton;
	private var _btnClearData:FlxButton;
	private var _btnBack:FlxButton;

	private var _save:FlxSave;

	override public function create():Void {
		_txtTitle = new FlxText(0, 20, 0, "Options", 22);
		_txtTitle.alignment = "center";
		_txtTitle.screenCenter(true, false);
		add(_txtTitle);

		_txtVolume = new FlxText(0, _txtTitle.y + _txtTitle.height + 10, 0, "Volume", 8);
		_txtVolume.alignment = "center";
		_txtVolume.screenCenter(true, false);
		add(_txtVolume);

		_btnVolumeDown = new FlxButton(8, _txtVolume.y + _txtVolume.height + 2, "-", clickVolumeDown);
		_btnVolumeDown.loadGraphic("assets/images/button.png", true, 20, 20);
		_btnVolumeDown.onUp.sound = FlxG.sound.load("assets/sounds/select.wav");
		add(_btnVolumeDown);

		_btnVolumeUp = new FlxButton(FlxG.width - 28, _btnVolumeDown.y, "+", clickVolumeUp);
		_btnVolumeUp.loadGraphic("assets/images/button.png", true, 20, 20);
		_btnVolumeUp.onUp.sound = FlxG.sound.load("assets/sounds/select.wav");
		add(_btnVolumeUp);

		_barVolume = new FlxBar(_btnVolumeDown.x + _btnVolumeDown.width + 4, _btnVolumeDown.y, 
			FlxBar.FILL_LEFT_TO_RIGHT, Std.int(FlxG.width - 64), Std.int(_btnVolumeUp.height));
		_barVolume.createFilledBar(FlxColor.CHARCOAL, FlxColor.WHITE, true, FlxColor.WHITE);
		add(_barVolume);

		_txtVolumeAmt = new FlxText(0, 0, 200, Std.string(FlxG.sound.volume * 100) + "%", 8);
		_txtVolumeAmt.alignment = "center";
		_txtVolumeAmt.borderStyle = FlxText.BORDER_OUTLINE;
		_txtVolumeAmt.borderColor = FlxColor.CHARCOAL;
		_txtVolumeAmt.y = _barVolume.y + (_barVolume.height/2) - (_txtVolumeAmt.height/2);
		_txtVolumeAmt.screenCenter(true, false);
		add(_txtVolumeAmt);

		_btnClearData = new FlxButton((FlxG.width/2) - 90, FlxG.height - 28, "Clear Data", clickClearData);
		_btnClearData.onUp.sound = FlxG.sound.load("assets/sounds/select.wav");
		add(_btnClearData);

		_btnBack = new FlxButton((FlxG.width/2) + 10, FlxG.height - 28, "Back", clickBack);
		_btnBack.onUp.sound = FlxG.sound.load("assets/sounds/select.wav");
		add(_btnBack);

		_save = new FlxSave();
		_save.bind("flixel-tutorial");

		updateVolume();

		super.create();
	}

	override public function destroy() {
		super.destroy();

		_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		_barVolume = FlxDestroyUtil.destroy(_barVolume);
		_txtVolume = FlxDestroyUtil.destroy(_txtVolume);
		_txtVolumeAmt = FlxDestroyUtil.destroy(_txtVolumeAmt);
		_btnVolumeDown = FlxDestroyUtil.destroy(_btnVolumeDown);
		_btnVolumeUp = FlxDestroyUtil.destroy(_btnVolumeUp);
		_btnClearData = FlxDestroyUtil.destroy(_btnClearData);
		_btnBack = FlxDestroyUtil.destroy(_btnBack);

		_save.destroy();
		_save = null;
	}

	/* Remove saved data and reset volume */
	private function clickClearData():Void {
		_save.erase();
		FlxG.sound.volume = 0.5;
		updateVolume();
	}

	private function clickBack():Void {
		_save.close();
		FlxG.switchState(new MenuState());
	}

	private function clickVolumeDown():Void {
		FlxG.sound.volume -= 0.1;
		_save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	private function clickVolumeUp():Void {
		FlxG.sound.volume += 0.1;
		_save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	private function updateVolume():Void {
		var vol:Int = Math.round(FlxG.sound.volume * 100);
		_barVolume.currentValue = vol;
		_txtVolumeAmt.text = Std.string(vol) + "%";
	}

}