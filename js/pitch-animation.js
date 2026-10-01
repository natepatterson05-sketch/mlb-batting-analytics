(() => {
  const animation = document.querySelector('.pitch-animation');
  if (!animation) return;
  const play = () => animation.classList.add('is-playing');
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) animation.classList.add('is-static');
  else if ('IntersectionObserver' in window) new IntersectionObserver((entries, observer) => {
    if (entries.some(entry => entry.isIntersecting)) { play(); observer.disconnect(); }
  }, {threshold: .4}).observe(animation);
  else play();
})();
