#include "uieffect.h"
#include "spritemanager.h"
#include <framework/graphics/drawqueue.h>

void UIEffect::drawSelf(Fw::DrawPane drawPane)
{
    if (drawPane != Fw::ForegroundPane)
        return;

    UIWidget::drawSelf(drawPane);

    if (m_effect) {
        // Pega a posição do widget e desenha o efeito
        Rect drawRect = Rect(getPaddingRect().topLeft(), getSize() * m_scale);
        m_effect->draw(drawRect.topLeft(), 0, 0, true); // A posição e animação são gerenciadas aqui
    }
}

void UIEffect::setEffect(const EffectPtr& effect)
{
    m_effect = effect;
    // m_effect->onAppear(); // Inicia a animação do efeito ao definir
}

void UIEffect::onStyleApply(const std::string& styleName, const OTMLNodePtr& styleNode)
{
    UIWidget::onStyleApply(styleName, styleNode);

    for (const OTMLNodePtr& node : styleNode->children()) {
        if (node->tag() == "scale") {
            setScale(node->value<float>());
        }
    }
}

void UIEffect::onGeometryChange(const Rect& oldRect, const Rect& newRect)
{
    UIWidget::onGeometryChange(oldRect, newRect);
}
