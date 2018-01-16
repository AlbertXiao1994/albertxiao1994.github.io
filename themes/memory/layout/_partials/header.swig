<div class="site-top-wrapper">
  {% if is_home %}
      <div class="site-overview">
        <div class="site-author" itemprop="author" itemscope itemtype="http://schema.org/Person">
          {% if theme.avatar %}
            <img class="site-author-image" itemprop="image"
              src="{{ url_for( theme.avatar | default(theme.images + '/avatar.gif') ) }}"
              alt="{{ theme.author }}" />
          {% endif %}
          <p class="site-author-name" itemprop="name">{{ theme.author }}</p>
        </div>

        {% if theme.site_state %}
          <nav class="site-state">
            {% if config.archive_dir != '/' and site.posts.length > 0 %}
              <div class="site-state-item site-state-posts">
                {% if theme.menu.archives %}
                  <a href="{{ url_for(theme.menu.archives).split('||')[0] | trim }}">
                {% else %}
                  <a href="{{ url_for(config.archive_dir) }}">
                {% endif %}
                  <span class="site-state-item-count">{{ site.posts.length }}</span>
                  <span class="site-state-item-name">{{ __('state.posts') }}</span>
                </a>
              </div>
            {% endif %}

            {% if site.categories.length > 0 %}
              {% set categoriesPageQuery = site.pages.find({type: 'categories'}, {lean: true}) %}
              {% set hasCategoriesPage = categoriesPageQuery.length > 0 %}
              <div class="site-state-item site-state-categories">
                {% if hasCategoriesPage %}<a href="{{ url_for(categoriesPageQuery[0].path) }}">{% endif %}
                  <span class="site-state-item-count">{{ site.categories.length }}</span>
                  <span class="site-state-item-name">{{ __('state.categories') }}</span>
                  {% if hasCategoriesPage %}</a>{% endif %}
              </div>
            {% endif %}

            {% if site.tags.length > 0 %}
              {% set tagsPageQuery = site.pages.find({type: 'tags'}, {lean: true}) %}
              {% set hasTagsPage = tagsPageQuery.length > 0 %}
              <div class="site-state-item site-state-tags">
                {% if hasTagsPage %}<a href="{{ url_for(tagsPageQuery[0].path) }}">{% endif %}
                  <span class="site-state-item-count">{{ site.tags.length }}</span>
                  <span class="site-state-item-name">{{ __('state.tags') }}</span>
                {% if hasTagsPage %}</a>{% endif %}
              </div>
            {% endif %}
          </nav>
        {% endif %}

        {% if theme.social %}
          <div class="links-of-author">
            {% for name, link in theme.social %}
              <span class="links-of-author-item">
                <a href="{{ link.split('||')[0] | trim }}" target="_blank" title="{{ name }}">
                  {% if theme.social_icons.enable %}
                    <i class="fa fa-fw fa-{{ link.split('||')[1] | trim | default('globe') }}"></i>{#
                    #}{% endif %}</a>
              </span>
            {% endfor %}
            <span class="links-of-author-item">
              <a href="" target="_blank" title="zhihu"><img src="./images/zhihu.png"></a>
            </span>
          </div>
        {% endif %}

      </div>

  {% endif %}
</div>

<div class="site-nav-toggle">
  <button>
    <span class="btn-bar"></span>
    <span class="btn-bar"></span>
    <span class="btn-bar"></span>
  </button>
</div>


<nav class="site-nav">
  {% set hasSearch = theme.swiftype_key || theme.algolia_search.enable || theme.tinysou_Key || theme.local_search.enable %}

  <div class="site-title"><a href="/">{{ config.title }}</a></div>

  {% if theme.menu %}
    <ul id="menu" class="menu">
      {% for name, path in theme.menu %}
        {% set itemName = name.toLowerCase() %}
        <li class="menu-item menu-item-{{ itemName | replace(' ', '-') }}">
          <a href="{{ url_for(path.split('||')[0]) | trim }}" rel="section">
            {% if theme.menu_settings.icons %}{#
            #}<i class="menu-item-icon fa fa-fw fa-{{ path.split('||')[1] | trim | default('question-circle') }}"></i>{#
          #}{% endif %}{#

          #}{% if theme.menu_settings.badges %}{#
            #}{% if name == 'archives' %}{#
              #}{{ __('menu.' + name) | replace('menu.', '') }}{#
              #}<span class="badge">{{ site.posts.length }}</span>
              {% elseif name == 'categories' %}{#
              #}{{ __('menu.' + name) | replace('menu.', '') }}{#
              #}<span class="badge">{{ site.categories.length }}</span>
              {% elseif name == 'tags' %}{#
              #}{{ __('menu.' + name) | replace('menu.', '') }}{#
              #}<span class="badge">{{ site.tags.length }}</span>
              {% else %}{#
              #}{{ __('menu.' + name) | replace('menu.', '') }}{#
            #}{% endif %}{#
          #}{% else %}{#
            #}{{ __('menu.' + name) | replace('menu.', '') }}{#
          #}{% endif %}{#

        #}</a>
        </li>
      {% endfor %}

      {% if hasSearch %}
        <li class="menu-item menu-item-search">
          {% if theme.swiftype_key %}
            <a href="javascript:;" class="st-search-show-outputs">
          {% elseif theme.local_search.enable || theme.algolia_search.enable %}
            <a href="javascript:;" class="popup-trigger">
          {% endif %}
            {% if theme.menu_settings.icons %}
              <i class="menu-item-icon fa fa-search fa-fw"></i>{#
          #}{% endif %}{#
          #}{{ __('menu.search') }}{#
        #}</a>
        </li>
      {% endif %}
    </ul>
  {% endif %}

  {% if hasSearch %}
    <div class="site-search">
      {% include 'search.swig' %}
    </div>
  {% endif %}
</nav>
