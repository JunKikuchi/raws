class RAWS::S3::Owner
  attr_reader :id, :display_name
  alias :name :display_name

  def initialize(owner)
    @id, @display_name = owner['ID'], owner['DisplayName']
  end
end
