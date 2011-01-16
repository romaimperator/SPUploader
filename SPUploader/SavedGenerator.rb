require File.dirname(__FILE__) + '/Generator'

# This is a high-level generator class to be used for any generator that only
# needs to be generated once but used in multiple pages and/or tags.
#   To use implement the following functions:
#     generate_value() - required
#       -returns a string
#   Do not override the value function since this is implemented for you in
#   this class. It generates the value from the generate_value function.

class SavedGenerator < Generator
  def initialize(value)
    super(value)
    @generated = false
  end


  # Returns the value of this generator. If the value hasn't been created yet
  #  then it generates is and saves it.
  def value
    if not @generated
      @generated = true
      @value = generate_value
    end
    return @value
  end


  # Returns a string from the generated value. Override this function to use as
  #  a saved-value generator.
  def generate_value
    ""
  end
end
