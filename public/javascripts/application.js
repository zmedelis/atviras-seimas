Ajax.Responders.register({
  onCreate: function() {
    if($('busy') && Ajax.activeRequestCount>0)
      Effect.Appear('busy',{duration:1,queue:'end'});
  },
  onComplete: function() {
    if($('busy') && Ajax.activeRequestCount==0)
      Effect.Fade('busy',{duration:1,queue:'end'});
  }
});

function startProgress() {
	Effect.Appear('busy');
}

function endProgress () {
	Effect.Fade('busy');
}
