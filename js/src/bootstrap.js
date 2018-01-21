/* global NexT: true */

$(document).ready(function () {

  $(document).trigger('bootstrap:before');

    /**
   * Register JS handlers by condition option.
   * Need to add config option in Front-End at 'layout/_partials/head.swig' file.
   */
  CONFIG.fastclick && NexT.utils.isMobile() && window.FastClick.attach(document.body);
  CONFIG.lazyload && NexT.utils.lazyLoadPostsImages();

  NexT.utils.registerESCKeyEvent();

  NexT.utils.registerBackToTop();

  // Mobile top menu bar.
  $('.site-nav-toggle button').on('click', function () {
    var $siteNav = $('.site-nav');
    var ON_CLASS_NAME = 'site-nav-on';
    var isSiteNavOn = $siteNav.hasClass(ON_CLASS_NAME);
    var display = isSiteNavOn ? 'none' : 'block';
    var overflow = isSiteNavOn ? 'auto' : 'hidden';
    var height = isSiteNavOn ? 'auto' : window.innerHeight + 'px';
    var animateAction = isSiteNavOn ? 'slideUp' : 'slideDown';
    var animateCallback = isSiteNavOn ? 'removeClass' : 'addClass';
    var $navDimmer = $('.nav-dimmer');
    var $overview = $('.site-overview-mobile');
    var $html = $('html');
    var $body = $('body');
    var $container = $('.container');

    $siteNav.stop()[animateAction]('fast', function () {
      $siteNav[animateCallback](ON_CLASS_NAME);
    });

    $navDimmer.stop()[animateAction]('fast', function () {
      $navDimmer[animateCallback](ON_CLASS_NAME);
    });

    // $navDimmer.css({'display':display});
    $overview.css({'display':display});
    $html.css({'overflow':overflow});
    $body.css({'overflow':overflow});
    $container.css({'height':height});
  });

  $('.nav-dimmer .nav-close').on('click', function () {
    $('.site-nav-toggle button').trigger('click');
  });

  /**
   * Register JS handlers by condition option.
   * Need to add config option in Front-End at 'layout/_partials/head.swig' file.
   */
  CONFIG.fancybox && NexT.utils.wrapImageWithFancyBox();
  CONFIG.tabs && NexT.utils.registerTabsTag();

  NexT.utils.embeddedVideoTransformer();
  NexT.utils.addActiveClassToMenuItem();


  // Define Motion Sequence.
  NexT.motion.integrator
    .add(NexT.motion.middleWares.logo)
    .add(NexT.motion.middleWares.menu)
    .add(NexT.motion.middleWares.postList)
    .add(NexT.motion.middleWares.sidebar);

  $(document).trigger('motion:before');

  // Bootstrap Motion.
  CONFIG.motion.enable && NexT.motion.integrator.bootstrap();

  $(document).trigger('bootstrap:after');
});
