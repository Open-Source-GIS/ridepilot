function Dispatcher (tree_id, map_id) {
  self           = this,
  this.tree      = null,
  this.map       = null,
  this.markers   = {},
  this._data     = null, 
  this._tree_elem  = $("#" + tree_id),
  this._map_elem = $("#" + map_id),
  
  this.init = function(map_id){
    $(window).resize(self.adjustMapHeight).resize();
    
    self.map = new google.maps.Map( document.getElementById(map_id), {
      zoom      : 11,
      mapTypeId : google.maps.MapTypeId.ROADMAP, 
      center    : new google.maps.LatLng(45.5234515, -122.6762071)
    });
    
    self.initTree();
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
      plugins   : [ "json_data", "themes", "checkbox", "ui" ],
      themes    : { theme : "apple" },
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
      } },
      checkbox  : { override_ui : true }
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
          marker ? 
            marker.setPosition( new google.maps.LatLng( this.metadata.lat, this.metadata.lng ) ) :
            self.createMarker(device_pool, this);
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
    
    self.markers[device.metadata.id] = marker;
    // google.maps.event.addListener(marker,"click",function(){});

    return marker;
  },
  
  this.refresh = function() {
    self._tree_elem.jstree("refresh");
  },
  
  this.uncheckNode = function(node){
    self._tree_elem.jstree("uncheck_node", node );
  },
  
  this.checkNode = function(node){
    self._tree_elem.jstree("check_node", node );
  },
  
  this.createNodeListeners = function(){      
    self._tree_elem.delegate("a","click", function(e) { 
      var node = $(this).parent("li"); 
      
      if (node.data().lat) // it's a marker
        return self.toggleVisibility( [self.markers[node.data().id.toString()]] );
      else {
        $.each( node.find("[rel=device]"), function(){
          return self.toggleVisibility( [self.markers[$(this).data().id.toString()]] );
        });
      }
    });     
  },
  
  this.toggleVisibility = function(markers){
    $.each(markers, function(){
      var marker = this;
      if (!marker.getMap()) marker.setMap(self.map);
      else marker.setMap(null);
    })
  };
  
  this.init(map_id);
}