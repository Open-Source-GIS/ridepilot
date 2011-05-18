def clean_address(addr)
  return addr if addr.blank?
  addr = addr.gsub(/\s+/,' ')
  addr = addr.strip
  addr = addr.gsub('.','')
  addr = addr.gsub(',','')
  addr = addr.gsub(/ nw /i,' NW ')
  addr = addr.gsub(/ sw /i,' SW ')
  addr = addr.gsub(/ se /i,' SE ')
  addr = addr.gsub(/ ne /i,' NE ')
  addr = addr.gsub(/ e /i,' E ')
  addr = addr.gsub(/ w /i,' W ')
  addr = addr.gsub(/ n /i,' N ')
  addr
end
