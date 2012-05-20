function Dispatcher (tree_id, map_id) {
  self           = this,
  this.tree      = null,
  this.map       = null,
  this.markers   = {},
  this._data     = null, 
  this._infoWindow = new google.maps.InfoWindow({ content : "" }),
  this._tree_elem  = $("#" + tree_id),
  this._map_elem = $("#" + map_id),
  this._timeout  = null,
  
  this.init = function(map_id){
    $(window).resize(self.adjustMapHeight).resize();
    
    self.map = new google.maps.Map( document.getElementById(map_id), {
      zoom      : 11,
      mapTypeId : google.maps.MapTypeId.ROADMAP, 
      center    : new google.maps.LatLng(45.5234515, -122.6762071)
    });
    
    google.maps.event.addListener(self.map, "click", function(){
      self._infoWindow.close();
    });
    
    self.initTree();
    
    self._resetRefreshTimer();
  },
  
  this.adjustMapHeight = function() {
    self._map_elem.css("height", function(){
      return $(window).height() -
      $("#header").outerHeight() -
      $("#crossbar").outerHeight() -
      ( $("#main").outerHeight() - $("#main").height() ) -
      $("#page-header").outerHeight() - 21 + "px"
    });
  },
  
  this.initTree = function(){
    self.tree = self._tree_elem.jstree({
      core      : { html_titles : true },
      plugins   : [ "json_data", "themes", "checkbox"],
      themes    : { theme : "apple", url : "../stylesheets/jstree-apple/style.css" },
      json_data : { ajax : {
        url : window.location.pathname,
        dataType : "json", 
        success : function(data) {
          self._data = data;
          
          self.positionMarkers();
          self.createNodeListeners();

          window.setTimeout(function(){
            self._tree_elem.jstree("open_all", -1);
            self._tree_elem.jstree("check_all");
          }, 1);
        }        
      } }
    });
  },
  
  this.positionMarkers = function() {
    if ( self.markers.length < 1 ) self.initMarkers();
    else self.updateMarkers();
  },
  
  this.initMarkers = function(){
    $.each(self._data, function(){
      $.each(this.children, function(){
        var device_pool = this;
        $.each(device_pool.children, function(){
          self.createMarker(device_pool, this);
        })
      })
    });
  }, 
  
  this.updateMarkers = function() {
    $.each(self._data, function(){
      $.each(this.children, function(){
        var device_pool = this;
        $.each(device_pool.children, function(){
          var marker = self.markers[this.metadata.id];
          if (marker) {
            marker.setPosition( new google.maps.LatLng( this.metadata.lat, this.metadata.lng ) );
            marker.html = self._marker_html(this.metadata);
          } else self.createMarker(device_pool, this);
        });
      });
    });
  },
  
  this.createMarker = function(device_pool, device) {
    var marker = new StyledMarker({
      styleIcon : new StyledIcon( StyledIconTypes.MARKER, { color : device_pool.attr["data-color"] } ),
      position  : new google.maps.LatLng( device.metadata.lat, device.metadata.lng ),
      map       : self.map
    });
    
    marker.html = self._marker_html(device.metadata);
    
    self.markers[device.metadata.id] = marker;
    google.maps.event.addListener(marker,"click",function(){
      self._open_window_for_marker(marker);
    });

    return marker;
  },
  
  this._marker_html = function(device) {
    return '<div class="marker_detail">\
      <h2>' + device.name + '</h2>\
      <h3>' + device.status + '</h3>\
      <h4>Updated: ' + device.posted_at + '</h4>\
    </div>';
  },
  
  this._open_window_for_marker = function(marker) {
    self._infoWindow.setContent(marker.html);
    self._infoWindow.open(self.map, marker);
  },
  
  
  this._resetRefreshTimer = function() {
    self._timeout = window.clearTimeout( self._timeout );
    self._timeout = window.setTimeout( self.refresh, 120000 );
  },
  
  this.refresh = function() {
    self._resetRefreshTimer();
    self._infoWindow.close();
    self._tree_elem.jstree("refresh");
  },
  
  this.uncheckNode = function(node){
    self._tree_elem.jstree("uncheck_node", node );
  },
  
  this.checkNode = function(node){
    self._tree_elem.jstree("check_node", node );
  },
    
  this.createNodeListeners = function(){   
    // Driver name click   
    self._tree_elem.delegate("a", "click.jstree", function(e) { 
      var node = $(this).parents("li").first();
      
      if (node.data().lat) { // it's a marker
        var marker = self.markers[node.data().id];
        self.map.setCenter( marker.getPosition() );
        self._open_window_for_marker( marker );
      }
    });
    
    // Checkbox click
    self._tree_elem.delegate("ins", "click.jstree", function(e) { 
      e.stopImmediatePropagation();
      
      var node = $(this).parents("li").first(); 
      if (node.data().lat) { // it's a marker
        if (node.hasClass("jstree-checked"))
          return self.showMarkers( [self.markers[node.data().id.toString()]] );
        else
          return self.hideMarkers( [self.markers[node.data().id.toString()]] );
      } else {
        $.each( node.find("[rel=device]"), function(){
          if (node.hasClass("jstree-checked"))
            return self.showMarkers( [self.markers[$(this).data().id.toString()]] );
          else
            return self.hideMarkers( [self.markers[$(this).data().id.toString()]] );
        });
      }
    });
    
  },
  
  this.hideMarkers = function(markers){
    $.each(markers, function(){
      var marker = this;
      marker.setMap(null);
    })
  };
  
  this.showMarkers = function(markers){
    $.each(markers, function(){
      var marker = this;
      marker.setMap(self.map);
    })
  };
  
  this.init(map_id);
}
