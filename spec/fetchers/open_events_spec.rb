require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe RMeetup::Fetcher::OpenEvents, 'fetching some Open Events' do
  before do
    @fetcher = RMeetup::Fetcher::OpenEvents.new
    @fetcher.extend(RMeetup::FakeResponse::OpenEvents)
  end

  it 'should return a collection of Events' do
    @fetcher.fetch.each do |result|
      result.should be_kind_of(RMeetup::Type::OpenEvent)
    end
  end
end