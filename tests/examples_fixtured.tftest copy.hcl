# This example code shows how you can run a test with pre-setup (test fixtures)
run "basic_fixture_setup" {
  command = apply
  module {
    source = "./tests/fixtures/base"
  }
}

run "validate_basic_example_with_fixtures" {
  command = apply
  module {
    source = "./examples/basic"
  }
}