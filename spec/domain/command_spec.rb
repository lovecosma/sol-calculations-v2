# frozen_string_literal: true

require "rails_helper"

RSpec.describe Command do
  let(:command_class) do
    Class.new do
      include Command
      option :value, optional: true, default: -> { nil }

      def run
        value
      end
    end
  end

  describe ".run" do
    it "instantiates the class and calls #run" do
      instance = instance_double(command_class, run: 42)
      allow(command_class).to receive(:new).and_return(instance)

      result = command_class.run
      expect(result).to eq(42)
    end

    it "passes keyword args to the constructor" do
      expect(command_class).to receive(:new).with(value: "hello").and_call_original
      command_class.run(value: "hello")
    end

    it "defaults to empty args when called with no arguments" do
      expect(command_class).to receive(:new).with(no_args).and_call_original
      command_class.run
    end

    it "returns the result of #run" do
      expect(command_class.run(value: "result")).to eq("result")
    end
  end

  describe ".included" do
    it "extends the includer with Dry::Initializer" do
      expect(command_class.singleton_class.ancestors).to include(Dry::Initializer)
    end

    it "defines a .run class method on the includer" do
      expect(command_class).to respond_to(:run)
    end
  end
end
