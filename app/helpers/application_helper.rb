module ApplicationHelper
  def get_base_url
	  @base_url = ENV['RAILS_RELATIVE_URL_ROOT'] ||= ''
  end

  def full_title(page_title)
    base_title = 'MTurk Rails'
    if page_title.empty? then
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def as_csv(array, column_names, *options)
    if column_names.nil?
      column_names = array.first.keys
    end
    CSV.generate(*options) do |csv|
      csv << column_names
      array.each do |item|
        csv << item.values_at(*column_names)
      end
    end
  end

  def get_path(url)
    if url && url.start_with?("/")
      @base_url + url
    else
      url
    end
  end

  def getImageUrl(fullId,viewId)
    if fullId
      host = "https://dovahkiin.stanford.edu/fuzzybox"
      parts = fullId.split(/\./, 2)
      id = parts[1] || parts[0]
      source = (parts.length > 1)? parts[0] : '3dw'
      if source == '3dw'
        prefixLength = 5
        screenShotsDir = host + "/shapenet/screenshots/models/" + source + "/"
      elsif source == 'yobi3d'
        prefixLength = 3
        screenShotsDir = host + "/shapenet/screenshots/models/" + source + "/"
      else
        prefixLength = 0
        screenShotsDir = host + "/text2scene/screenshots/models/" + source + "/"
      end
      if viewId >= 0
        prefix = getPrefixedLoadPath(screenShotsDir, prefixLength, id)
        imageUrl = prefix + id + "-" + viewId.to_s + ".png"
      else
        prefix = getPrefixedLoadPath(host + "/shapenet/data/", prefixLength, id)
        imageUrl = prefix + "Image/" + id
      end
      imageUrl
    else
      ""
    end
  end

  def getPrefixedLoadPath(baseDir, prefixLength, id)
    prefix = id.slice(0,prefixLength)
    rest = id.slice(prefixLength,id.length-prefixLength)
    path = baseDir
    for i in 0...prefix.length
      path = path + prefix[i] + "/";
    end
    path = path + rest + "/" + id + "/"
    path
  end

end
