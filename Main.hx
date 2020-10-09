import stx.log.Facade;
using stx.data.Table;
using stx.data.Store;

class Main {
	static function main() {
		var log_facade = Facade.unit();
				log_facade.includes.push("stx.db");
				//log_facade.

		stx.data.Test.main();
	}
}
