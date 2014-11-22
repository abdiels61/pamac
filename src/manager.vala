/*
 *  pamac-vala
 *
 *  Copyright (C) 2014  Guillaume Benoit <guillaume@manjaro.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a get of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Pamac {

	public class Manager : Gtk.Application {
		ManagerWindow manager_window;
		bool pamac_run;

		public Manager () {
			application_id = "org.manjaro.pamac.manager";
			flags = ApplicationFlags.FLAGS_NONE;
		}

		public override void startup () {
			// i18n
			Intl.textdomain ("pamac");
			Intl.setlocale (LocaleCategory.ALL, "");

			base.startup ();

			pamac_run = check_pamac_running ();
			if (pamac_run) {
				var transaction_info_dialog = new TransactionInfoDialog (null);
				transaction_info_dialog.set_title (dgettext (null, "Error"));
				transaction_info_dialog.label.set_visible (true);
				transaction_info_dialog.label.set_markup (dgettext (null, "Pamac is already running"));
				transaction_info_dialog.expander.set_visible (false);
				transaction_info_dialog.run ();
				transaction_info_dialog.hide ();
			} else
				manager_window = new ManagerWindow (this);
		}

		public override void activate () {
			if (pamac_run == false) {
				manager_window.present ();
				while (Gtk.events_pending ())
					Gtk.main_iteration ();
				manager_window.show_all_pkgs ();
			}
		}

		public override void shutdown () {
			base.shutdown ();
			if (pamac_run == false)
				manager_window.transaction.stop_daemon ();
		}

		bool check_pamac_running () {
			Application app;
			bool run = false;
			app = new Application ("org.manjaro.pamac.updater", 0);
			try {
				app.register ();
			} catch (GLib.Error e) {
				stderr.printf ("%s\n", e.message);
			}
			run =  app.get_is_remote ();
			if (run)
				return run;
			else {
				app = new Application ("org.manjaro.pamac.install", 0);
				try {
					app.register ();
				} catch (GLib.Error e) {
					stderr.printf ("%s\n", e.message);
				}
				run =  app.get_is_remote ();
				return run;
			}
		}
	}

	public static int main (string[] args) {
		var manager = new Manager ();
		return manager.run (args);
	}
}
