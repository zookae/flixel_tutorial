package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
using flixel.util.FlxSpriteUtil;

class CombatHUD extends FlxTypedGroup<FlxSprite> {

	/* store outcomes of combat */
	public var e:Enemy; // enemy for combat
	public var playerHealth(default, null):Int; // player remaining health
	public var outcome(default,null):Outcome; // player kill / flee

	/* combat sprites */
	private var _sprBack:FlxSprite;
	private var _sprPlayer:Player;
	private var _sprEnemy:Enemy;

	/* enemy health */
	private var _enemyHealth:Int;
	private var _enemyMaxHealth:Int;
	private var _enemyHealthBar:FlxBar;

	private var _txtPlayerHealth:FlxText; // player current/max health
	private var _damages:Array<FlxText>; // 2 FlxText objects: damage dealt or misses

	private var _pointer:FlxSprite; // pointer to show option user is selecting
	private var _selected:Int = 0; // track option being selected
	private var _choices:Array<FlxText>; // 2 FlxText objects: Fight, Flee

	private var _results:FlxText; // FlxText for outcome of battle

	private var _alpha:Float = 0; // fade in/out HUD
	private var _wait:Bool = true; // use to block player action (b/t turns)

	public function new() {
		super();

		/* create background:
			(1) blank square
			(2) white borders
			(3) add to group 
		*/
		_sprBack = new FlxSprite().makeGraphic(120, 120, FlxColor.WHITE);
		_sprBack.drawRect(1, 1, 118, 44, FlxColor.BLACK);
		_sprBack.drawRect(1, 46, 118, 73, FlxColor.BLACK);
		_sprBack.screenCenter(true, true);
		add(_sprBack);

		/* add in-combat player */
		_sprPlayer = new Player(_sprBack.x + 36, _sprBack.y + 16);
		_sprPlayer.animation.frameIndex = 3;
		_sprPlayer.active = false;
		_sprPlayer.facing = FlxObject.RIGHT;
		add(_sprPlayer);

		/* add in-combat enemy; change type later */
		_sprEnemy = new Enemy(_sprBack.x + 76, _sprBack.y + 16, 0);
		_sprEnemy.animation.frameIndex = 3;
		_sprEnemy.active = false;
		_sprEnemy.facing = FlxObject.LEFT;
		add(_sprEnemy);

		/* create player health display */
		_txtPlayerHealth = new FlxText(0, _sprPlayer.y + _sprPlayer.height + 2, 0 , "3 / 3", 8);
		_txtPlayerHealth.alignment = "center";
		_txtPlayerHealth.x = _sprPlayer.x + 4 - (_txtPlayerHealth.width / 2);
		add(_txtPlayerHealth);

		/* use FlxBar to show enemy health from RED to YELLOW */
		_enemyHealthBar = new FlxBar(_sprEnemy.x - 6, _txtPlayerHealth.y, FlxBar.FILL_LEFT_TO_RIGHT, 20, 10);
		_enemyHealthBar.createFilledBar(FlxColor.CRIMSON, FlxColor.YELLOW, true, FlxColor.YELLOW);
		add(_enemyHealthBar);

		/* create choices */
		_choices = new Array<FlxText>();
		_choices.push(new FlxText(_sprBack.x + 30, _sprBack.y + 48, 85, "FIGHT", 22));
		_choices.push(new FlxText(_sprBack.x + 30, _choices[0].y + _choices[0].height + 8, 85, "FLEE", 22));
		add(_choices[0]);
		add(_choices[1]);

		_pointer = new FlxSprite(_sprBack.x + 10, _choices[0].y + (_choices[0].height/2) - 8, "assets/images/pointer.png");
		_pointer.visible = false;
		add(_pointer);

		/* create damage text display */
		_damages = new Array<FlxText>();
		_damages.push(new FlxText(0,0,40));
		_damages.push(new FlxText(0,0,40));
		for (d in _damages) {
			d.color = FlxColor.WHITE;
			d.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.RED);
			d.alignment = "center";
			d.visible = false;
			add(d);
		}

		/* create combat results object and hide it */
		_results = new FlxText(_sprBack.x + 2, _sprBack.y + 9, 116, "", 18);
		_results.alignment = "center";
		_results.color = FlxColor.YELLOW;
		_results.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY);
		_results.visible = false;
		add(_results);

		/* fix on screen regardless of camera; start alpha at 0 */
		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
			spr.alpha = 0;
		});

		/* mark object as not active or visible yet */
		active = false;
		visible = false;
	}

	/**
	*	Used to start combat: initializes screen and parameters
	*	@param 	PlayerHealth 	The amount of health the player starts with
	*	@param 	E 				The enemy being fought
	*/
	public function initCombat(PlayerHealth:Int, E:Enemy):Void {
		playerHealth = PlayerHealth;
		e = E;

		updatePlayerHealth(); // update player health text

		// set up enemy
		_enemyMaxHealth = _enemyHealth = (e.etype + 1) * 2; // enemy health based on type; 0 = 2 health, 1 = 4 health
		_enemyHealthBar.currentValue = 100; // start at 100%
		_sprEnemy.changeEnemy(e.etype); // change enemy image to match type

		// initialize values
		_wait = true;
		_results.text = "";
		_pointer.visible = false;
		_results.visible = false;
		outcome = NONE;
		_selected = 0;

		visible = true;
		// do numeric tween to fade in hud; when finished call finishFadeIn
		FlxTween.num(0, 1, 0.66, 
			{ ease:FlxEase.circOut, complete:finishFadeIn }, updateAlpha);
	}

	/* fade in/out items in the HUD */
	private function updateAlpha(Value:Float):Void {
		_alpha = Value;
		forEach(function(spr:FlxSprite) {
			spr.alpha = _alpha;
		});
	}

	/* set HUD to active after finishing tween */
	private function finishFadeIn(_):Void {
		active = true;
		_wait = false;
		_pointer.visible = true;
	}

	/* disable HUD after fade out */
	private function finishFadeOut(_):Void {
		active = false;
		visible = false;
	}

	/* change player health text on screen */
	private function updatePlayerHealth():Void {
		_txtPlayerHealth.text = Std.string(playerHealth) + " / 3";
		_txtPlayerHealth.x = _sprPlayer.x + 4 - (_txtPlayerHealth.width / 2);
	}

	override public function update():Void {
		if (!_wait) {
			// flags for keys pressed
			var _up:Bool = false;
			var _down:Bool = false;
			var _fire:Bool = false;

			// check button presses, set flags
			if (FlxG.keys.anyJustReleased(["SPACE", "X"])) {
				_fire = true;
			}
			else if (FlxG.keys.anyJustReleased(["W", "UP"])) {
				_up = true;
			}
			else if (FlxG.keys.anyJustReleased(["S", "DOWN"])) {
				_down = true;
			}

			// take action based on flags
			if (_fire) {
				makeChoice();
			}
			else if (_up) {
				if (_selected == 0) {
					_selected = 1;
				}
				else {
					_selected--;
				}
				movePointer();
			}
			else if (_down) {
				if (_selected == 1) {
					_selected = 0;
				}
				else {
					_selected++;
				}
				movePointer();
			}
		}
		super.update();
	}

	/* adjust point to indicate current selection */
	private function movePointer():Void {
		_pointer.y = _choices[_selected].y + (_choices[_selected].height / 2) - 8;
	}

	/* process player choices */
	private function makeChoice():Void {
		_pointer.visible = false;
		switch(_selected) {
			case 0:
				// choice 0 = FIGHT

				// player attacks first, has 85% hit chance
				if (FlxRandom.chanceRoll(85)) {
					_damages[1].text = "1"; // hit deals 1 damage
					_enemyHealth--;
					_enemyHealthBar.currentValue = (_enemyHealth / _enemyMaxHealth) * 100;
				}
				else {
					_damages[1].text = "MISS!";
				}

				_damages[1].x = _sprEnemy.x + 2 - (_damages[1].width / 2);
				_damages[1].y = _sprEnemy.y + 2 - (_damages[1].height / 2);
				_damages[1].alpha = 0;
				_damages[1].visible = true;

				if (_enemyHealth > 0) {
					enemyAttack();
				}

				// tweens to fade in + float up damage indicators
				FlxTween.num(_damages[0].y, _damages[0].y - 12, 1, { ease:FlxEase.circOut }, updateDamageY);
				FlxTween.num(0, 1, 0.2, { ease:FlxEase.circInOut, complete:doneDamageIn }, updateDamageAlpha);

			case 1:
				// choice 1 = FLEE

				// 50% chance to escape
				if (FlxRandom.chanceRoll(50)) {
					outcome = ESCAPE;
					_results.text = "ESCAPED!";
					_results.visible = true;
					_results.alpha = 0;
					FlxTween.tween(_results, {alpha:1}, 0.66, {ease:FlxEase.circInOut, complete:doneResultsIn});
				}
				else {
					enemyAttack();
					FlxTween.num(_damages[0].y, _damages[0].y - 12, 1, {ease:FlxEase.circOut}, updateDamageY);
					FlxTween.num(0, 1, 0.2, {ease:FlxEase.circInOut, complete:doneDamageIn}, updateDamageAlpha);
				}
		}

		_wait = true; // wait to show what happened before continuing
	}

	private function enemyAttack():Void {
		// 30% chance for enemy to hit
		if (FlxRandom.chanceRoll(30)) {
			FlxG.camera.flash(FlxColor.WHITE, 0.2);
			_damages[0].text = "1";
			playerHealth--;
			updatePlayerHealth();
		}
		else {
			_damages[0].text = "MISS!";
		}

		_damages[0].x = _sprPlayer.x + 2 - (_damages[0].width / 2);
		_damages[0].y = _sprPlayer.y + 2 - (_damages[0].height / 2);
		_damages[0].alpha = 0;
		_damages[0].visible = true;
	}

	private function updateDamageY(Value:Float):Void {
		_damages[0].y = _damages[1].y = Value;
	}

	private function updateDamageAlpha(Value:Float):Void {
		_damages[0].alpha = _damages[1].alpha = Value;
	}

	/* called after damage text is done fading in; causes fading out after a delay */
	private function doneDamageIn(_):Void {
		FlxTween.num(1, 0, 0.66, {ease:FlxEase.circInOut, startDelay:1, complete:doneDamageOut}, updateDamageAlpha);
	}

	/* triggered when results text finishes fading in; fade out entire HUD if not defeated */
	private function doneResultsIn(_):Void {
		if (outcome != DEFEAT) {
			FlxTween.num(1, 0, 0.66, {ease:FlxEase.circOut, startDelay:1, complete:finishFadeOut}, updateAlpha);
		}
	}


	/* trigger after damage texts have faded out
	*	(1) clear and reset damage texts
	*	(2) handle outcomes
	*/
	private function doneDamageOut(_):Void {
		_damages[0].visible = false;
		_damages[1].visible = false;
		_damages[0].text = "";
		_damages[1].text = "";

		if (playerHealth <= 0) {
			outcome = DEFEAT;
			_results.text = "DEFEAT!";
			_results.visible = true;
			_results.alpha = 0;
			FlxTween.tween(_results, {alpha:1}, 0.66, {ease:FlxEase.circInOut, complete:doneResultsIn});
		}
		else if (_enemyHealth <= 0) {
			outcome = VICTORY;
			_results.text = "VICTORY!";
			_results.visible = true;
			_results.alpha = 0;
			FlxTween.tween(_results, {alpha:1}, 0.66, {ease:FlxEase.circInOut, complete:doneResultsIn});
		}
		else {
			// both are alive, so reset and have player pick next action
			_wait = false;
			_pointer.visible = true;
		}
	}

}

/* enum for valid outcome variable values */
enum Outcome {
	NONE;
	ESCAPE;
	VICTORY;
	DEFEAT;
}
