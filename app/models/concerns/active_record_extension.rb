# Our custom extensions to active record
module ActiveRecordExtension
  extend ActiveSupport::Concern

  # add your instance methods here
  def without_timestamping
    class << self
      def record_timestamps; false; end
    end
    yield
  ensure
    class << self
      remove_method :record_timestamps
    end
  end

  # add your static(class) methods here
  module ClassMethods
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)