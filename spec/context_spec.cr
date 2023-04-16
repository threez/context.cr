require "./spec_helper"

describe Fiber do
  it "handles an empty context correctly" do
    f = Fiber.current

    f.inspect_values.should eq ""
    f[:foo]?.should eq nil
  end

  it "failes to request an unknown context value" do
    expect_raises(Exception) do
      Fiber.current[:foo]
    end
  end

  it "can store and shadow a value" do
    f = Fiber.current

    f.with_values foo: "123" do
      f[:foo].should eq "123"
      f.with_values foo: "456", bar: "789" do
        f[:foo].should eq "456"
        f.inspect_values.should eq "foo: \"456\", bar: \"789\""
      end
      f[:foo].should eq "123"
    end

    f[:foo]?.should eq nil
  end

  it "can use a new empty context" do
    f = Fiber.current

    f.with_values foo: "123" do
      f[:foo].should eq "123"
      f.with_empty_values bar: "456" do
        f[:bar].should eq "456"
        f[:foo]?.should eq nil
        f.inspect_values.should eq "bar: \"456\""
      end
      f[:foo].should eq "123"
    end

    f[:foo]?.should eq nil
  end

  it "can iterate over the context values" do
    f = Fiber.current

    f.each_value do
      raise "should not iterate on empty values"
    end

    f.with_values foo: "123" do
      f.each_value do |key, value|
        key.should eq :foo
        value.should eq "123"
      end
    end

    f.with_values foo: "123" do
      f.with_empty_values do
        f.each_value do
          raise "should not iterate on empty values"
        end
      end
    end
  end
end
