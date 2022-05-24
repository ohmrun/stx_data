using stx.Nano;
using stx.Log;

using stx.data.Table;
using stx.data.Store;

class Main {
	static function main() {
		var logger = __.log().global;
				logger.includes.push("stx/db");
				//log_facade.

		stx.data.Test.main();
	}
}
