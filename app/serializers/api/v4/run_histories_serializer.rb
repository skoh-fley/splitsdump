class Api::V4::RunHistoriesSerializer < Api::V4::ApplicationSerializer
  attributes :attempt_number, :realtime_duration_ms, :gametime_duration_ms
end
