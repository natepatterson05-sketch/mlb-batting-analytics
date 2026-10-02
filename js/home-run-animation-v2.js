(() => {
  const animation = document.querySelector('.home-run-animation');
  if (!animation) return;
  const play = () => {
    if (animation.dataset.played) return;
    animation.dataset.played = 'true';
    animation.classList.add('is-playing');
  };
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    animation.classList.add('is-static');
    return;
  }
  if ('IntersectionObserver' in window) new IntersectionObserver((entries, observer) => {
    if (entries.some(entry => entry.isIntersecting)) { play(); observer.disconnect(); }
  }, {threshold: .45}).observe(animation);
  else play();
})();
