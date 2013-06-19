
def latest_backup(bucket_name, access_key_id, secret_access_key)

  s3 = AWS::S3.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
  bucket = s3.buckets[bucket_name]
  if bucket.nil? || !bucket.exists?
    raise "Unable to locate aws bucket [#{bucket_name}]."
  end

  items = Array.new
  bucket.objects.each do |obj|
    items.push obj if obj.key.end_with? '.tar.gz'
  end

  if items.empty?
    return nil
  end

  items.sort! { |a,b| b.last_modified <=> a.last_modified }
  items.first.key

end
