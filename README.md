pixijs-docset
=============
[Pixi.js](http://www.pixijs.com/) docset generator for [Dash](http://kapeli.com/dash).




System Requirements
-------------------
- Ruby 2.0 and above
- RubyGems
  - nokogiri
  - sqlite3
- Git




Generating Docset
-----------------
1. Install required gems if not installed yet:
	```
	$ gem install nokogiri sqlite3
	```

2. Execute a generator script:
	```
	$ cd path/to/pixijs-docset
	$ ruby docset.rb
	```

3. Open `docset/Pixijs.docset` and import it




License
-------
MIT License. See `LICENSE.txt` for more information.
