#
# Author:: Christopher Peplin (<peplin@bueda.com>)
# Copyright:: Copyright (c) 2010 Bueda, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Provider
    class S3File < Chef::Provider::RemoteFile
      def action_create
        sources = @new_resource.source
        source = sources
        # Handle the Chef 10.x use case along with 11.x
        if sources.respond_to?(:shift)
          source = sources.shift
        end
        Chef::Log.debug("Checking #{@new_resource} for changes")

        if current_resource_matches_target_checksum?
          Chef::Log.debug("File #{@new_resource} checksum matches target checksum (#{@new_resource.checksum}), not updating")
        else
          Chef::Log.debug("File #{@current_resource} checksum didn't match target checksum (#{@new_resource.checksum}), updating")
          fetch_from_s3(source) do |raw_file|
            if matches_current_checksum?(raw_file)
              Chef::Log.debug "#{@new_resource}: Target and Source checksums are the same, taking no action"
            else
              backup_new_resource
              Chef::Log.debug "copying remote file from origin #{raw_file.path} to destination #{@new_resource.path}"
              FileUtils.cp raw_file.path, @new_resource.path
              @new_resource.updated_by_last_action(true)
            end
          end
        end

        enforce_ownership_and_permissions

        @new_resource.updated_by_last_action?
      end

      def fetch_from_s3(source)
        begin
          require 'aws-sdk'
          protocol, bucket, name = URI.split(source).compact
          name = name[1..-1]
          region = 'us-east-1'
          Chef::Log.debug("Downloading #{name} from S3 bucket #{bucket}")
          client = Aws::S3::Client.new(region: region, credentials: Aws::Credentials.new(@new_resource.access_key_id, @new_resource.secret_access_key))          
          tmp_file = Tempfile.new("chef-#{name}")
          begin
            client.get_object({bucket: bucket, key: name}, target: tmp_file)
            yield tmp_file                    
          ensure
            tmp_file.close
            tmp_file.unlink
          end
        rescue URI::InvalidURIError
          Chef::Log.warn("Expected an S3 URL but found #{source}")
          nil
        end
      end
    end
  end
end

class Chef
  class Resource
    class S3File < Chef::Resource::RemoteFile
      def initialize(name, run_context=nil)
        super
        @resource_name = :s3_file
      end

      def provider
        Chef::Provider::S3File
      end

      def access_key_id(args=nil)
        set_or_return(
            :access_key_id,
            args,
            :kind_of => String
        )
      end

      def secret_access_key(args=nil)
        set_or_return(
            :secret_access_key,
            args,
            :kind_of => String
        )
      end
    end
  end
end