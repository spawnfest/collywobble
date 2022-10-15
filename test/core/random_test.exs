defmodule Core.RandomTest do
  use Test.SimpleCase

  describe "string" do
    test "creates a random string with N characters" do
      assert Core.Random.string(4) =~ ~r/^[a-zA-Z0-9\-_]{4}$/
      assert Core.Random.string(40) =~ ~r/^[a-zA-Z0-9\-_]{40}$/
    end
  end
end
