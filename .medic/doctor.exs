[
  {Medic.Checks.Homebrew, :bundled?},
  {Medic.Checks.Hex, :local_hex_installed?},
  {Medic.Checks.Hex, :local_rebar_installed?},
  {Medic.Checks.Hex, :packages_installed?},
  {Medic.Checks.Postgres, :role_exists?, ["postgres"]},
  {Medic.Checks.Postgres, :database_exists?, ["collywobble_dev", username: "postgres"]}
]
