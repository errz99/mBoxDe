import std.stdio;
import std.typecons;
import std.conv;

import gtk.Widget;
import gtk.Box;
import gtk.Label;
import gtk.EventBox;
import gtk.Button;

class MBox : Box {
	private:
	bool _hasHead;
	Label[][] _labels;
	string[][] _data;
	string[][] _datax;
	int _position;
	int _outPosition = -1;
	int _lastPosition = -1;
	string[2] headMarkup;
	string[2] dataMarkup;
	string[2] cursorMarkup;

	void createDatax() {
		import std.array : replicate;
		import std.uni : byGrapheme;
		import std.range.primitives : walkLength;

		if (_data.length == 0) {
			return;
		}

		int separation = 1;
		auto sep = " ".replicate(separation);

		ulong[] max;
		max.length = _data[0].length;

		for (int j = 0; j < max.length; j++) {
			for (int i = 0; i < _data.length; i++) {
				auto elemgr = _data[i][j].byGrapheme;
				if (elemgr.walkLength > max[j]) {
					max[j] = elemgr.walkLength;
				}
			}
		}

		for (int i = 0; i < _data.length; i++) {
			string[] row;

			for (int j = 0; j < _data[i].length; j++) {
				auto elemgr = _data[i][j].byGrapheme;
				ulong grow = max[j] - elemgr.walkLength;
				string elemx = sep ~ _data[i][j] ~ " ".replicate(grow) ~ sep;
				row ~= elemx;
			}
			_datax ~= row;
		}
	}

	public:
	this(string[][] data, bool hasHead) {
		_hasHead = hasHead;
		if (_hasHead == true) {
			_outPosition++;
		}
		_position = _outPosition;
		_lastPosition = _outPosition;

		string hma = "<span><tt><b>";
		string hmb = "</b></tt></span>";
		string dma = "<span background=\"white\"><tt>";
		string dmb = "</tt></span>";
		string cma = "<span foreground=\"white\" background=\"#6666dd\"><tt>";
		string cmb = "</tt></span>";

		headMarkup = [hma, hmb];
		dataMarkup = [dma, dmb];
		cursorMarkup = [cma, cmb];

		_data = data;
		createDatax();

		super(Orientation.VERTICAL, 4);
		setHalign(Align.CENTER);

		foreach (d; _datax) {
			auto row = new Box(Orientation.HORIZONTAL, 4);
			add(row);
			Label[] rowLabels;

			foreach (elemx; d) {
				auto ebox = new EventBox;
				row.add(ebox);
				auto label = new Label(elemx);
				label.setMarkup(dataMarkup[0] ~ elemx ~ dataMarkup[1]);
				ebox.add(label);
				rowLabels ~= label;
			}
			_labels ~= rowLabels;
		}

		if (_hasHead == true && _labels.length > 0) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[0][i].setMarkup(headMarkup[0] ~ _datax[0][i] ~ headMarkup[1]);
			}
		}
	}

	string[] getRow(int n) {
		return _data[n];
	}

	void cursorDown() {
		_lastPosition = _position;
		_position++;
		if (_position == _data.length) {
			_position = _outPosition + 1;
		}
		updateCursor();
	}

	void cursorUp() {
		_lastPosition = _position;
		_position--;
		if (_position < _outPosition + 1) {
			_position = to!int(_data.length) - 1;
		}
		updateCursor();
	}

	void updateCursor() {
		if (_position > _outPosition) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[_position][i].setMarkup(
					cursorMarkup[0] ~ _datax[_position][i] ~ cursorMarkup[1]);
			}
		}
		if (_lastPosition > _outPosition) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[_lastPosition][i].setMarkup(
					dataMarkup[0] ~ _datax[_lastPosition][i] ~ dataMarkup[1]);
			}
		}
	}

	bool cursorIsActive() {
		if (_position > _outPosition) {
			return true;
		} else {
			return false;
		}
	}

	void clearCursor() {
		if (_position > _outPosition) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[_position][i].setMarkup(
					dataMarkup[0] ~ _datax[_position][i] ~ dataMarkup[1]);
			}
			_position = _outPosition;
		}
	}

	string[] activeData() {
		auto pos = _position;
		if (_hasHead == true && _position == _outPosition) {
			pos = -1;
		}
		if (pos >= 0) {
			return _data[pos];
		} else {
			return [];
		}
	}
}
