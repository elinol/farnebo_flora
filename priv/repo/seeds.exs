# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FarneboFlora.Repo.insert!(%FarneboFlora.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Import plants from the data file
Mix.Task.run("import_plants", ["priv/data/flora.txt"])
